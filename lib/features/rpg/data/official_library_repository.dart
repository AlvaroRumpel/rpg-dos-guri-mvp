import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/domain.dart';

class OfficialLibrary {
  const OfficialLibrary({
    required this.races,
    required this.classes,
    required this.progression,
    required this.spells,
    required this.rituals,
    required this.powers,
    required this.equipment,
    required this.items,
    required this.starterKits,
    required this.monsters,
  });

  final List<RaceTemplate> races;
  final List<ClassTemplate> classes;
  final List<ClassProgressionEntry> progression;
  final List<SpellTemplate> spells;
  final List<RitualTemplate> rituals;
  final List<PowerTemplate> powers;
  final List<EquipmentTemplate> equipment;
  final List<ItemTemplate> items;
  final List<StarterKitTemplate> starterKits;
  final List<MonsterTemplate> monsters;
}

class OfficialLibraryRepository {
  OfficialLibraryRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle,
      _useSharedCache = bundle == null;

  final AssetBundle _bundle;
  final bool _useSharedCache;
  static Future<OfficialLibrary>? _sharedLoad;

  Future<OfficialLibrary> load() async {
    if (_useSharedCache) {
      return _sharedLoad ??= _load();
    }
    return _load();
  }

  Future<OfficialLibrary> _load() async {
    final results = await Future.wait([
      _readList('assets/data/official/races.json'),
      _readList('assets/data/official/classes.json'),
      _readList('assets/data/official/progression.json'),
      _readList('assets/data/official/spells.json'),
      _readList('assets/data/official/rituals.json'),
      _readList('assets/data/official/powers.json'),
      _readList('assets/data/official/equipment.json'),
      _readList('assets/data/official/items.json'),
      _readList('assets/data/official/starter_kits.json'),
      _readList('assets/data/official/monsters.json'),
    ]);

    return OfficialLibrary(
      races: results[0].map(_raceFromJson).toList(),
      classes: results[1].map(_classFromJson).toList(),
      progression: results[2].map(_progressionFromJson).toList(),
      spells: results[3].map(_spellFromJson).toList(),
      rituals: results[4].map(_ritualFromJson).toList(),
      powers: results[5].map(_powerFromJson).toList(),
      equipment: results[6].map(_equipmentFromJson).toList(),
      items: results[7].map(_itemFromJson).toList(),
      starterKits: results[8].map(_starterKitFromJson).toList(),
      monsters: results[9].map(_monsterFromJson).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _readList(String path) async {
    final raw = await _bundle.loadString(path);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

RaceTemplate _raceFromJson(Map<String, dynamic> json) {
  return RaceTemplate(
    id: _string(json['id'], 'race'),
    name: _string(json['name'], 'Raca'),
    identity: _string(json['identity']),
    powerName: _string(json['powerName'], 'Poder racial'),
    powerDescription: _string(json['powerDescription']),
    powerEffect: _string(json['powerEffect']),
    usageLimit: _usageLimit(json['usageLimit']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    roll: _nullableString(json['roll']),
    damage: _nullableString(json['damage']),
    healing: _nullableString(json['healing']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

ClassTemplate _classFromJson(Map<String, dynamic> json) {
  return ClassTemplate(
    id: _string(json['id'], 'class'),
    name: _string(json['name'], 'Classe'),
    role: _string(json['role']),
    skills: _stringList(json['skills']),
    initialPowerName: _string(json['initialPowerName']),
    description: _nullableString(json['description']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

ClassProgressionEntry _progressionFromJson(Map<String, dynamic> json) {
  return ClassProgressionEntry(
    id: _string(json['id'], 'progression'),
    characterClass: _string(json['characterClass'], 'Guerreiro'),
    level: _int(json['level'], 1),
    name: _string(json['name'], 'Habilidade'),
    description: _string(json['description']),
    usageLimit: _usageLimit(json['usageLimit']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    roll: _nullableString(json['roll']),
    damage: _nullableString(json['damage']),
    healing: _nullableString(json['healing']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

SpellTemplate _spellFromJson(Map<String, dynamic> json) {
  return SpellTemplate(
    id: _string(json['id'], 'spell'),
    name: _string(json['name'], 'Magia'),
    tier: _string(json['tier'], 'Magia simples'),
    description: _string(json['description']),
    suggestedTest: _string(json['suggestedTest'], 'Conforme situacao'),
    effect: _string(json['effect']),
    usageLimit: _usageLimit(json['usageLimit']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    roll: _nullableString(json['roll']),
    damage: _nullableString(json['damage']),
    healing: _nullableString(json['healing']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

RitualTemplate _ritualFromJson(Map<String, dynamic> json) {
  return RitualTemplate(
    id: _string(json['id'], 'ritual'),
    name: _string(json['name'], 'Ritual'),
    suggestedRoll: _string(json['suggestedRoll'], 'Conforme situacao'),
    description: _string(json['description']),
    difficulty: _string(json['difficulty']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    effect: _nullableString(json['effect']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

PowerTemplate _powerFromJson(Map<String, dynamic> json) {
  return PowerTemplate(
    id: _string(json['id'], 'power'),
    name: _string(json['name'], 'Poder'),
    type: _string(json['type'], 'Poder'),
    description: _string(json['description']),
    suggestedTest: _string(json['suggestedTest'], 'Conforme situacao'),
    effect: _string(json['effect']),
    usageLimit: _usageLimit(json['usageLimit']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    roll: _nullableString(json['roll']),
    damage: _nullableString(json['damage']),
    healing: _nullableString(json['healing']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

EquipmentTemplate _equipmentFromJson(Map<String, dynamic> json) {
  return EquipmentTemplate(
    id: _string(json['id'], 'equipment'),
    name: _string(json['name'], 'Equipamento'),
    category: _equipmentCategory(json['category']),
    description: _string(json['description']),
    damage: _nullableString(json['damage']),
    attribute: _nullableString(json['attribute']),
    properties: _stringList(json['properties']),
    recommendedClasses: _stringList(json['recommendedClasses']),
    baseDefense: _nullableInt(json['baseDefense']),
    defenseBonus: _int(json['defenseBonus']),
    origin: _nullableString(json['origin']),
    usageLimit: json['usageLimit'] == null
        ? null
        : _usageLimit(json['usageLimit']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    roll: _nullableString(json['roll']),
    effect: _nullableString(json['effect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

ItemTemplate _itemFromJson(Map<String, dynamic> json) {
  return ItemTemplate(
    id: _string(json['id'], 'item'),
    name: _string(json['name'], 'Item'),
    type: _string(json['type'], 'Item util'),
    description: _string(json['description']),
    defaultQuantity: _int(json['defaultQuantity'], 1),
    roll: _nullableString(json['roll']),
    fixedBonus: _int(json['fixedBonus']),
    effectKind: _nullableString(json['effectKind']),
    origin: _nullableString(json['origin']),
    actionCost: _nullableString(json['actionCost']),
    range: _nullableString(json['range']),
    duration: _nullableString(json['duration']),
    extraEffect: _nullableString(json['extraEffect']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

StarterKitTemplate _starterKitFromJson(Map<String, dynamic> json) {
  return StarterKitTemplate(
    id: _string(json['id'], 'kit'),
    name: _string(json['name'], 'Kit inicial'),
    characterClass: _string(json['characterClass']),
    items: _stringList(json['items']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

MonsterTemplate _monsterFromJson(Map<String, dynamic> json) {
  return MonsterTemplate(
    id: _string(json['id'], 'monster'),
    name: _string(json['name'], 'Monstro'),
    category: _string(json['category'], 'Monstro'),
    defense: _int(json['defense'], 10),
    maxHp: _int(json['maxHp'], 1),
    attack: _string(json['attack'], '1d20'),
    damage: _string(json['damage'], '1'),
    movement: _string(json['movement'], 'Normal'),
    instinct: _string(json['instinct']),
    special: _string(json['special']),
    description: _string(json['description']),
    behavior: _nullableString(json['behavior']),
    encounterUse: _nullableString(json['encounterUse']),
    rewards: _nullableString(json['rewards']),
    notes: _nullableString(json['notes']),
    source: _nullableString(json['source']),
  );
}

String _string(Object? value, [String fallback = '']) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

String? _nullableString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

int _int(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().map((item) => item.trim()).toList();
}

UsageLimit _usageLimit(Object? value) {
  final name = value is String ? value : '';
  for (final item in UsageLimit.values) {
    if (item.name == name) return item;
  }
  return UsageLimit.free;
}

EquipmentCategory _equipmentCategory(Object? value) {
  final name = value is String ? value : '';
  for (final item in EquipmentCategory.values) {
    if (item.name == name) return item;
  }
  return EquipmentCategory.weapon;
}
