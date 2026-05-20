import '../models/rpg_models.dart';

RpgTable tableFromMap(String id, Map<String, dynamic> data) {
  return RpgTable(
    id: id,
    name: data['name'] as String? ?? 'RPG dos Guri',
    code: data['code'] as String? ?? 'GURI-1234',
    pendingPlayerNames: _stringList(data['pendingPlayerNames']),
    activeCombatId: data['activeCombatId'] as String?,
  );
}

Map<String, dynamic> tableToMap(RpgTable table) {
  return {
    'name': table.name,
    'code': table.code,
    'pendingPlayerNames': table.pendingPlayerNames,
    'activeCombatId': table.activeCombatId,
  };
}

CharacterSheet characterFromMap(String id, Map<String, dynamic> data) {
  return CharacterSheet(
    id: id,
    name: data['name'] as String? ?? 'Personagem',
    race: data['race'] as String? ?? 'Humano',
    characterClass: data['characterClass'] as String? ?? 'Guerreiro',
    level: _int(data['level'], fallback: 1),
    concept: data['concept'] as String? ?? '',
    attributes: _intMap(data['attributes']),
    skills: _intMap(data['skills']),
    currentHp: _int(data['currentHp'], fallback: 10),
    armor: data['armor'] as String? ?? 'Sem armadura',
    hasShield: data['hasShield'] as bool? ?? false,
    mainWeapon: data['mainWeapon'] as String? ?? 'Arma simples',
    secondaryItem: data['secondaryItem'] as String? ?? 'Item secundario',
    accessories: _stringList(data['accessories']),
    powers: _mapList(data['powers']).map(powerFromMap).toList(),
    inventory: _mapList(data['inventory']).map(inventoryItemFromMap).toList(),
    statuses: _mapList(data['statuses']).map(statusFromMap).toList(),
    coins: _int(data['coins']),
    ownerName: data['ownerName'] as String?,
  );
}

Map<String, dynamic> characterToMap(CharacterSheet character) {
  return {
    'name': character.name,
    'race': character.race,
    'characterClass': character.characterClass,
    'level': character.level,
    'concept': character.concept,
    'attributes': character.attributes,
    'skills': character.skills,
    'currentHp': character.currentHp,
    'armor': character.armor,
    'hasShield': character.hasShield,
    'mainWeapon': character.mainWeapon,
    'secondaryItem': character.secondaryItem,
    'accessories': character.accessories,
    'powers': character.powers.map(powerToMap).toList(),
    'inventory': character.inventory.map(inventoryItemToMap).toList(),
    'statuses': character.statuses.map(statusToMap).toList(),
    'coins': character.coins,
    'ownerName': character.ownerName,
  };
}

PowerEntry powerFromMap(Map<String, dynamic> data) {
  return PowerEntry(
    id: data['id'] as String? ?? 'power',
    name: data['name'] as String? ?? 'Poder',
    type: data['type'] as String? ?? 'Poder',
    description: data['description'] as String? ?? '',
    suggestedTest: data['suggestedTest'] as String? ?? '',
    effect: data['effect'] as String? ?? '',
    usageLimit:
        _enumByName(UsageLimit.values, data['usageLimit'] as String?) ??
        UsageLimit.free,
    used: data['used'] as bool? ?? false,
  );
}

Map<String, dynamic> powerToMap(PowerEntry power) {
  return {
    'id': power.id,
    'name': power.name,
    'type': power.type,
    'description': power.description,
    'suggestedTest': power.suggestedTest,
    'effect': power.effect,
    'usageLimit': power.usageLimit.name,
    'used': power.used,
  };
}

InventoryItem inventoryItemFromMap(Map<String, dynamic> data) {
  return InventoryItem(
    id: data['id'] as String? ?? 'item',
    name: data['name'] as String? ?? 'Item',
    type: data['type'] as String? ?? 'Item util',
    quantity: _int(data['quantity'], fallback: 1),
    description: data['description'] as String? ?? '',
    roll: data['roll'] as String?,
    fixedBonus: _int(data['fixedBonus']),
    effectKind: data['effectKind'] as String?,
  );
}

Map<String, dynamic> inventoryItemToMap(InventoryItem item) {
  return {
    'id': item.id,
    'name': item.name,
    'type': item.type,
    'quantity': item.quantity,
    'description': item.description,
    'roll': item.roll,
    'fixedBonus': item.fixedBonus,
    'effectKind': item.effectKind,
  };
}

StatusEntry statusFromMap(Map<String, dynamic> data) {
  return StatusEntry(
    id: data['id'] as String? ?? 'status',
    name: data['name'] as String? ?? 'Status',
    type: data['type'] as String? ?? 'Narrativo',
    description: data['description'] as String? ?? '',
    duration: data['duration'] as String?,
    visibleToPlayer: data['visibleToPlayer'] as bool? ?? true,
  );
}

Map<String, dynamic> statusToMap(StatusEntry status) {
  return {
    'id': status.id,
    'name': status.name,
    'type': status.type,
    'description': status.description,
    'duration': status.duration,
    'visibleToPlayer': status.visibleToPlayer,
  };
}

CombatState combatFromMap(String id, Map<String, dynamic> data) {
  return CombatState(
    id: id,
    active: data['active'] as bool? ?? false,
    round: _int(data['round'], fallback: 1),
    participants: _mapList(
      data['participants'],
    ).map(combatParticipantFromMap).toList(),
  );
}

Map<String, dynamic> combatToMap(CombatState combat) {
  return {
    'active': combat.active,
    'round': combat.round,
    'participants': combat.participants.map(combatParticipantToMap).toList(),
  };
}

CombatParticipant combatParticipantFromMap(Map<String, dynamic> data) {
  return CombatParticipant(
    id: data['id'] as String? ?? 'participant',
    name: data['name'] as String? ?? 'Participante',
    type:
        _enumByName(ParticipantType.values, data['type'] as String?) ??
        ParticipantType.npcNeutral,
    currentHp: _int(data['currentHp']),
    maxHp: _int(data['maxHp'], fallback: 1),
    defense: _int(data['defense'], fallback: 10),
    statuses: _mapList(data['statuses']).map(statusFromMap).toList(),
    sourceCharacterId: data['sourceCharacterId'] as String?,
    damageSuggestion: data['damageSuggestion'] as String?,
    defeatedState:
        _enumByName(DefeatedState.values, data['defeatedState'] as String?) ??
        DefeatedState.active,
  );
}

Map<String, dynamic> combatParticipantToMap(CombatParticipant participant) {
  return {
    'id': participant.id,
    'name': participant.name,
    'type': participant.type.name,
    'currentHp': participant.currentHp,
    'maxHp': participant.maxHp,
    'defense': participant.defense,
    'statuses': participant.statuses.map(statusToMap).toList(),
    'sourceCharacterId': participant.sourceCharacterId,
    'damageSuggestion': participant.damageSuggestion,
    'defeatedState': participant.defeatedState.name,
  };
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: _int(entry.value),
  };
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

T? _enumByName<T extends Enum>(List<T> values, String? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
