import '../domain/domain.dart';

abstract class TableRepository {
  Stream<RpgTable?> watchTable(String tableId);

  Future<void> saveTable(RpgTable table);

  Future<RpgTable?> findByCode(String code);
}

abstract class CharacterRepository {
  Stream<List<CharacterSheet>> watchCharacters(String tableId);

  Future<void> saveCharacter(String tableId, CharacterSheet character);

  Future<void> deleteCharacter(String tableId, String characterId);
}

abstract class CombatRepository {
  Stream<CombatState?> watchActiveCombat(String tableId);

  Future<void> saveCombat(String tableId, CombatState combat);

  Future<void> finishCombat(String tableId, String combatId);
}

abstract class LibraryRepository {
  Stream<List<MonsterTemplate>> watchMonsters();

  Stream<List<PowerTemplate>> watchPowers();

  Stream<List<SpellTemplate>> watchSpells();

  Stream<List<ItemTemplate>> watchItems();
}

abstract class ActionLogRepository {
  Stream<List<String>> watchRecent(String tableId);

  Future<void> add(String tableId, String message);
}
