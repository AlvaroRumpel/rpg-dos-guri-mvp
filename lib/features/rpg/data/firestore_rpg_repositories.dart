import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rpg_models.dart';
import 'rpg_firestore_mappers.dart';
import 'rpg_repositories.dart';

class FirestoreTableRepository implements TableRepository {
  FirestoreTableRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tables =>
      _firestore.collection('tables');

  @override
  Stream<RpgTable?> watchTable(String tableId) {
    return _tables.doc(tableId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return tableFromMap(snapshot.id, data);
    });
  }

  @override
  Future<void> saveTable(RpgTable table) {
    return _tables
        .doc(table.id)
        .set(tableToMap(table), SetOptions(merge: true));
  }

  @override
  Future<RpgTable?> findByCode(String code) async {
    final snapshot = await _tables
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return tableFromMap(doc.id, doc.data());
  }
}

class FirestoreCharacterRepository implements CharacterRepository {
  FirestoreCharacterRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _characters(String tableId) {
    return _firestore
        .collection('tables')
        .doc(tableId)
        .collection('characters');
  }

  @override
  Stream<List<CharacterSheet>> watchCharacters(String tableId) {
    return _characters(tableId).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => characterFromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
    );
  }

  @override
  Future<void> saveCharacter(String tableId, CharacterSheet character) {
    return _characters(
      tableId,
    ).doc(character.id).set(characterToMap(character), SetOptions(merge: true));
  }

  @override
  Future<void> deleteCharacter(String tableId, String characterId) {
    return _characters(tableId).doc(characterId).delete();
  }
}

class FirestoreCombatRepository implements CombatRepository {
  FirestoreCombatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _combats(String tableId) {
    return _firestore.collection('tables').doc(tableId).collection('combats');
  }

  @override
  Stream<CombatState?> watchActiveCombat(String tableId) {
    return _combats(
      tableId,
    ).where('active', isEqualTo: true).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return combatFromMap(doc.id, doc.data());
    });
  }

  @override
  Future<void> saveCombat(String tableId, CombatState combat) {
    return _combats(
      tableId,
    ).doc(combat.id).set(combatToMap(combat), SetOptions(merge: true));
  }

  @override
  Future<void> finishCombat(String tableId, String combatId) {
    return _combats(
      tableId,
    ).doc(combatId).set({'active': false}, SetOptions(merge: true));
  }
}

class FirestoreLibraryRepository implements LibraryRepository {
  const FirestoreLibraryRepository();

  @override
  Stream<List<MonsterTemplate>> watchMonsters() => const Stream.empty();

  @override
  Stream<List<PowerTemplate>> watchPowers() => const Stream.empty();

  @override
  Stream<List<SpellTemplate>> watchSpells() => const Stream.empty();

  @override
  Stream<List<ItemTemplate>> watchItems() => const Stream.empty();
}

class FirestoreActionLogRepository implements ActionLogRepository {
  FirestoreActionLogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _logs(String tableId) {
    return _firestore.collection('tables').doc(tableId).collection('logs');
  }

  @override
  Stream<List<String>> watchRecent(String tableId) {
    return _logs(tableId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['message'] as String? ?? '')
              .where((message) => message.isNotEmpty)
              .toList(),
        );
  }

  @override
  Future<void> add(String tableId, String message) {
    return _logs(
      tableId,
    ).add({'message': message, 'createdAt': FieldValue.serverTimestamp()});
  }
}
