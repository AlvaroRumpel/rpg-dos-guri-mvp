import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:rpg_dos_guri/features/rpg/application/application.dart';
import 'package:rpg_dos_guri/features/rpg/data/rpg_repositories.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  test('persiste somente os domínios alterados após o debounce', () async {
    final tables = _TableRepository();
    final characters = _CharacterRepository();
    final combats = _CombatRepository();
    final controller = RpgSessionController.firestore(
      tableRepository: tables,
      characterRepository: characters,
      combatRepository: combats,
      actionLogRepository: _ActionLogRepository(),
    );
    addTearDown(controller.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 500));
    tables.saved = 0;
    characters.savedIds.clear();
    combats.saved = 0;

    controller.requestPlayerApproval('Novo jogador');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(tables.saved, 1);
    expect(characters.savedIds, isEmpty);
    expect(combats.saved, 0);

    tables.saved = 0;
    controller.updateCharacter(
      controller.characters.first.copyWith(concept: 'Conceito atualizado'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(tables.saved, 0);
    expect(characters.savedIds, [controller.characters.first.id]);
    expect(combats.saved, 0);
  });
}

class _TableRepository implements TableRepository {
  int saved = 0;

  @override
  Stream<RpgTable?> watchTable(String tableId) => const Stream.empty();

  @override
  Future<void> saveTable(RpgTable table) async {
    saved += 1;
  }

  @override
  Future<RpgTable?> findByCode(String code) async => null;
}

class _CharacterRepository implements CharacterRepository {
  final List<String> savedIds = [];

  @override
  Stream<List<CharacterSheet>> watchCharacters(String tableId) =>
      const Stream.empty();

  @override
  Future<void> saveCharacter(String tableId, CharacterSheet character) async {
    savedIds.add(character.id);
  }

  @override
  Future<void> deleteCharacter(String tableId, String characterId) async {}
}

class _CombatRepository implements CombatRepository {
  int saved = 0;

  @override
  Stream<CombatState?> watchActiveCombat(String tableId) =>
      const Stream.empty();

  @override
  Future<void> saveCombat(String tableId, CombatState combat) async {
    saved += 1;
  }

  @override
  Future<void> finishCombat(String tableId, String combatId) async {}
}

class _ActionLogRepository implements ActionLogRepository {
  @override
  Stream<List<String>> watchRecent(String tableId) => const Stream.empty();

  @override
  Future<void> add(String tableId, String message) async {}
}
