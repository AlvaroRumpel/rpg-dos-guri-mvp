import '../domain/domain.dart';

RpgTable tableFromMap(String id, Map<String, dynamic> data) {
  return RpgTable(
    id: id,
    name: data['name'] as String? ?? 'RPG dos Guri',
    code: data['code'] as String? ?? 'GURI-1234',
    pendingPlayerNames: _stringList(data['pendingPlayerNames']),
    powerUseRequests: _mapList(
      data['powerUseRequests'],
    ).map(powerUseRequestFromMap).toList(),
    masterNotes: _mapList(
      data['masterNotes'],
    ).map(campaignNoteFromMap).toList(),
    storyPoints: _mapList(data['storyPoints']).map(storyPointFromMap).toList(),
    customNpcs: _mapList(data['customNpcs']).map(customNpcFromMap).toList(),
    masterPinHash: data['masterPinHash'] as String?,
    activeCombatId: data['activeCombatId'] as String?,
  );
}

Map<String, dynamic> tableToMap(RpgTable table) {
  return _withoutNulls({
    'name': table.name,
    'code': table.code,
    'pendingPlayerNames': table.pendingPlayerNames,
    'powerUseRequests': table.powerUseRequests
        .map(powerUseRequestToMap)
        .toList(),
    'masterNotes': table.masterNotes.map(campaignNoteToMap).toList(),
    'storyPoints': table.storyPoints.map(storyPointToMap).toList(),
    'customNpcs': table.customNpcs.map(customNpcToMap).toList(),
    'masterPinHash': table.masterPinHash,
    'activeCombatId': table.activeCombatId,
  });
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
    notes: _mapList(data['notes']).map(campaignNoteFromMap).toList(),
    ownerName: data['ownerName'] as String?,
    archived: data['archived'] as bool? ?? false,
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
    'notes': character.notes.map(campaignNoteToMap).toList(),
    'ownerName': character.ownerName,
    'archived': character.archived,
  };
}

CampaignNote campaignNoteFromMap(Map<String, dynamic> data) {
  final createdAt = _dateTime(data['createdAt']);
  return CampaignNote(
    id: data['id'] as String? ?? 'note',
    createdAt: createdAt,
    updatedAt: _dateTime(data['updatedAt'], fallback: createdAt),
    title: data['title'] as String? ?? '',
    body: data['body'] as String? ?? '',
  );
}

Map<String, dynamic> campaignNoteToMap(CampaignNote note) {
  return {
    'id': note.id,
    'createdAt': note.createdAt.toIso8601String(),
    'updatedAt': note.updatedAt.toIso8601String(),
    'title': note.title,
    'body': note.body,
  };
}

StoryPoint storyPointFromMap(Map<String, dynamic> data) {
  final createdAt = _dateTime(data['createdAt']);
  return StoryPoint(
    id: data['id'] as String? ?? 'story',
    createdAt: createdAt,
    updatedAt: _dateTime(data['updatedAt'], fallback: createdAt),
    title: data['title'] as String? ?? '',
    body: data['body'] as String? ?? '',
    order: _int(data['order']),
    status: data['status'] as String? ?? 'ideia',
  );
}

Map<String, dynamic> storyPointToMap(StoryPoint point) {
  return {
    'id': point.id,
    'createdAt': point.createdAt.toIso8601String(),
    'updatedAt': point.updatedAt.toIso8601String(),
    'title': point.title,
    'body': point.body,
    'order': point.order,
    'status': point.status,
  };
}

CustomNpc customNpcFromMap(Map<String, dynamic> data) {
  final createdAt = _dateTime(data['createdAt']);
  return CustomNpc(
    id: data['id'] as String? ?? 'npc',
    createdAt: createdAt,
    updatedAt: _dateTime(data['updatedAt'], fallback: createdAt),
    name: data['name'] as String? ?? '',
    race: data['race'] as String? ?? '',
    occupation: data['occupation'] as String? ?? '',
    appearance: data['appearance'] as String? ?? '',
    description: data['description'] as String? ?? '',
    personality: data['personality'] as String? ?? '',
    goal: data['goal'] as String? ?? '',
    storyHook: data['storyHook'] as String? ?? '',
    notes: data['notes'] as String? ?? '',
  );
}

Map<String, dynamic> customNpcToMap(CustomNpc npc) {
  return {
    'id': npc.id,
    'createdAt': npc.createdAt.toIso8601String(),
    'updatedAt': npc.updatedAt.toIso8601String(),
    'name': npc.name,
    'race': npc.race,
    'occupation': npc.occupation,
    'appearance': npc.appearance,
    'description': npc.description,
    'personality': npc.personality,
    'goal': npc.goal,
    'storyHook': npc.storyHook,
    'notes': npc.notes,
  };
}

PowerUseRequest powerUseRequestFromMap(Map<String, dynamic> data) {
  return PowerUseRequest(
    id: data['id'] as String? ?? 'request',
    characterId: data['characterId'] as String? ?? '',
    characterName: data['characterName'] as String? ?? 'Personagem',
    powerId: data['powerId'] as String? ?? '',
    powerName: data['powerName'] as String? ?? 'Poder',
    usageLimit:
        _enumByName(UsageLimit.values, data['usageLimit'] as String?) ??
        UsageLimit.free,
    createdAt: _dateTime(data['createdAt']),
  );
}

Map<String, dynamic> powerUseRequestToMap(PowerUseRequest request) {
  return {
    'id': request.id,
    'characterId': request.characterId,
    'characterName': request.characterName,
    'powerId': request.powerId,
    'powerName': request.powerName,
    'usageLimit': request.usageLimit.name,
    'createdAt': request.createdAt.toIso8601String(),
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
    origin: data['origin'] as String?,
    actionCost: data['actionCost'] as String?,
    range: data['range'] as String?,
    duration: data['duration'] as String?,
    roll: data['roll'] as String?,
    damage: data['damage'] as String?,
    healing: data['healing'] as String?,
    extraEffect: data['extraEffect'] as String?,
    notes: data['notes'] as String?,
    source: data['source'] as String?,
    used: data['used'] as bool? ?? false,
  );
}

Map<String, dynamic> powerToMap(PowerEntry power) {
  return _withoutNulls({
    'id': power.id,
    'name': power.name,
    'type': power.type,
    'description': power.description,
    'suggestedTest': power.suggestedTest,
    'effect': power.effect,
    'usageLimit': power.usageLimit.name,
    'origin': power.origin,
    'actionCost': power.actionCost,
    'range': power.range,
    'duration': power.duration,
    'roll': power.roll,
    'damage': power.damage,
    'healing': power.healing,
    'extraEffect': power.extraEffect,
    'notes': power.notes,
    'source': power.source,
    'used': power.used,
  });
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
    origin: data['origin'] as String?,
    actionCost: data['actionCost'] as String?,
    range: data['range'] as String?,
    duration: data['duration'] as String?,
    extraEffect: data['extraEffect'] as String?,
    howItWorks: data['howItWorks'] as String?,
    power: data['power'] as String?,
    history: data['history'] as String?,
    appearance: data['appearance'] as String?,
    notes: data['notes'] as String?,
    source: data['source'] as String?,
  );
}

Map<String, dynamic> inventoryItemToMap(InventoryItem item) {
  return _withoutNulls({
    'id': item.id,
    'name': item.name,
    'type': item.type,
    'quantity': item.quantity,
    'description': item.description,
    'roll': item.roll,
    'fixedBonus': item.fixedBonus,
    'effectKind': item.effectKind,
    'origin': item.origin,
    'actionCost': item.actionCost,
    'range': item.range,
    'duration': item.duration,
    'extraEffect': item.extraEffect,
    'howItWorks': item.howItWorks,
    'power': item.power,
    'history': item.history,
    'appearance': item.appearance,
    'notes': item.notes,
    'source': item.source,
  });
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
    sourceMonsterId: data['sourceMonsterId'] as String?,
    damageSuggestion: data['damageSuggestion'] as String?,
    defeatedState:
        _enumByName(DefeatedState.values, data['defeatedState'] as String?) ??
        DefeatedState.active,
    activeWeaponSlot:
        _enumByName(
          ActiveWeaponSlot.values,
          data['activeWeaponSlot'] as String?,
        ) ??
        ActiveWeaponSlot.primary,
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
    'sourceMonsterId': participant.sourceMonsterId,
    'damageSuggestion': participant.damageSuggestion,
    'defeatedState': participant.defeatedState.name,
    'activeWeaponSlot': participant.activeWeaponSlot.name,
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

Map<String, dynamic> _withoutNulls(Map<String, dynamic> value) {
  return {
    for (final entry in value.entries)
      if (entry.value != null) entry.key: entry.value,
  };
}

DateTime _dateTime(Object? value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }
  return fallback ?? DateTime.now();
}
