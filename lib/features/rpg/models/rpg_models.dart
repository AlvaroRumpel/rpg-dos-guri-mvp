enum UserRole { landing, master, player }

enum ParticipantType { player, monster, npcAlly, npcNeutral, npcEnemy, object }

enum UsageLimit { free, combat, session, longRest }

enum DefeatedState { active, unconscious, defeated, dead }

const _unset = Object();

class RaceTemplate {
  const RaceTemplate({
    required this.id,
    required this.name,
    required this.identity,
    required this.powerName,
    required this.powerDescription,
    required this.powerEffect,
    required this.usageLimit,
  });

  final String id;
  final String name;
  final String identity;
  final String powerName;
  final String powerDescription;
  final String powerEffect;
  final UsageLimit usageLimit;

  PowerEntry toPowerEntry() {
    return PowerEntry(
      id: '$id-racial-${DateTime.now().microsecondsSinceEpoch}',
      name: powerName,
      type: 'Poder racial',
      description: powerDescription,
      suggestedTest: 'Conforme situacao',
      effect: powerEffect,
      usageLimit: usageLimit,
    );
  }
}

class ClassTemplate {
  const ClassTemplate({
    required this.id,
    required this.name,
    required this.role,
    required this.skills,
    required this.initialPowerName,
  });

  final String id;
  final String name;
  final String role;
  final List<String> skills;
  final String initialPowerName;
}

enum EquipmentCategory { weapon, shield, armor, accessory }

class EquipmentTemplate {
  const EquipmentTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.damage,
    this.attribute,
    this.properties = const [],
    this.recommendedClasses = const [],
    this.baseDefense,
    this.defenseBonus = 0,
  });

  final String id;
  final String name;
  final EquipmentCategory category;
  final String description;
  final String? damage;
  final String? attribute;
  final List<String> properties;
  final List<String> recommendedClasses;
  final int? baseDefense;
  final int defenseBonus;
}

class RitualTemplate {
  const RitualTemplate({
    required this.id,
    required this.name,
    required this.suggestedRoll,
    required this.description,
    required this.difficulty,
  });

  final String id;
  final String name;
  final String suggestedRoll;
  final String description;
  final String difficulty;
}

class StarterKitTemplate {
  const StarterKitTemplate({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.items,
  });

  final String id;
  final String name;
  final String characterClass;
  final List<String> items;
}

class RpgTable {
  const RpgTable({
    required this.id,
    required this.name,
    required this.code,
    this.pendingPlayerNames = const [],
    this.activeCombatId,
  });

  final String id;
  final String name;
  final String code;
  final List<String> pendingPlayerNames;
  final String? activeCombatId;

  RpgTable copyWith({
    String? name,
    String? code,
    List<String>? pendingPlayerNames,
    Object? activeCombatId = _unset,
  }) {
    return RpgTable(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      pendingPlayerNames: pendingPlayerNames ?? this.pendingPlayerNames,
      activeCombatId: identical(activeCombatId, _unset)
          ? this.activeCombatId
          : activeCombatId as String?,
    );
  }
}

class CharacterSheet {
  const CharacterSheet({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.concept,
    required this.attributes,
    required this.skills,
    required this.currentHp,
    required this.armor,
    required this.hasShield,
    required this.mainWeapon,
    required this.secondaryItem,
    required this.accessories,
    required this.powers,
    required this.inventory,
    required this.statuses,
    required this.coins,
    this.ownerName,
  });

  final String id;
  final String name;
  final String race;
  final String characterClass;
  final int level;
  final String concept;
  final Map<String, int> attributes;
  final Map<String, int> skills;
  final int currentHp;
  final String armor;
  final bool hasShield;
  final String mainWeapon;
  final String secondaryItem;
  final List<String> accessories;
  final List<PowerEntry> powers;
  final List<InventoryItem> inventory;
  final List<StatusEntry> statuses;
  final int coins;
  final String? ownerName;

  int get maxHp => 10 + (attributes['Vigor'] ?? 0);

  int get defense {
    final base = switch (armor) {
      'Armadura leve' => 11,
      'Armadura media' => 12,
      'Armadura média' => 12,
      'Armadura pesada' => 13,
      _ => 10,
    };
    return base + (hasShield ? 1 : 0);
  }

  CharacterSheet copyWith({
    String? name,
    String? race,
    String? characterClass,
    int? level,
    String? concept,
    Map<String, int>? attributes,
    Map<String, int>? skills,
    int? currentHp,
    String? armor,
    bool? hasShield,
    String? mainWeapon,
    String? secondaryItem,
    List<String>? accessories,
    List<PowerEntry>? powers,
    List<InventoryItem>? inventory,
    List<StatusEntry>? statuses,
    int? coins,
    String? ownerName,
  }) {
    return CharacterSheet(
      id: id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      concept: concept ?? this.concept,
      attributes: attributes ?? this.attributes,
      skills: skills ?? this.skills,
      currentHp: currentHp ?? this.currentHp,
      armor: armor ?? this.armor,
      hasShield: hasShield ?? this.hasShield,
      mainWeapon: mainWeapon ?? this.mainWeapon,
      secondaryItem: secondaryItem ?? this.secondaryItem,
      accessories: accessories ?? this.accessories,
      powers: powers ?? this.powers,
      inventory: inventory ?? this.inventory,
      statuses: statuses ?? this.statuses,
      coins: coins ?? this.coins,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}

class PowerEntry {
  const PowerEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.suggestedTest,
    required this.effect,
    required this.usageLimit,
    this.used = false,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String suggestedTest;
  final String effect;
  final UsageLimit usageLimit;
  final bool used;

  PowerEntry copyWith({bool? used}) {
    return PowerEntry(
      id: id,
      name: name,
      type: type,
      description: description,
      suggestedTest: suggestedTest,
      effect: effect,
      usageLimit: usageLimit,
      used: used ?? this.used,
    );
  }
}

class PowerTemplate {
  const PowerTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.suggestedTest,
    required this.effect,
    required this.usageLimit,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String suggestedTest;
  final String effect;
  final UsageLimit usageLimit;

  PowerEntry toEntry() {
    return PowerEntry(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: type,
      description: description,
      suggestedTest: suggestedTest,
      effect: effect,
      usageLimit: usageLimit,
    );
  }
}

class SpellTemplate {
  const SpellTemplate({
    required this.id,
    required this.name,
    required this.tier,
    required this.description,
    required this.suggestedTest,
    required this.effect,
    required this.usageLimit,
  });

  final String id;
  final String name;
  final String tier;
  final String description;
  final String suggestedTest;
  final String effect;
  final UsageLimit usageLimit;

  PowerEntry toEntry() {
    return PowerEntry(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: tier,
      description: description,
      suggestedTest: suggestedTest,
      effect: effect,
      usageLimit: usageLimit,
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.description,
    this.roll,
    this.fixedBonus = 0,
    this.effectKind,
  });

  final String id;
  final String name;
  final String type;
  final int quantity;
  final String description;
  final String? roll;
  final int fixedBonus;
  final String? effectKind;

  InventoryItem copyWith({
    String? name,
    String? type,
    int? quantity,
    String? description,
    String? roll,
    int? fixedBonus,
    String? effectKind,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      roll: roll ?? this.roll,
      fixedBonus: fixedBonus ?? this.fixedBonus,
      effectKind: effectKind ?? this.effectKind,
    );
  }
}

class ItemTemplate {
  const ItemTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.defaultQuantity = 1,
    this.roll,
    this.fixedBonus = 0,
    this.effectKind,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final int defaultQuantity;
  final String? roll;
  final int fixedBonus;
  final String? effectKind;

  InventoryItem toItem({int? quantity}) {
    return InventoryItem(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: type,
      quantity: quantity ?? defaultQuantity,
      description: description,
      roll: roll,
      fixedBonus: fixedBonus,
      effectKind: effectKind,
    );
  }
}

class ClassProgressionEntry {
  const ClassProgressionEntry({
    required this.id,
    required this.characterClass,
    required this.level,
    required this.name,
    required this.description,
    required this.usageLimit,
  });

  final String id;
  final String characterClass;
  final int level;
  final String name;
  final String description;
  final UsageLimit usageLimit;

  PowerEntry toPowerEntry() {
    return PowerEntry(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: 'Habilidade de classe',
      description: description,
      suggestedTest: 'Conforme situacao',
      effect: description,
      usageLimit: usageLimit,
    );
  }
}

class StatusEntry {
  const StatusEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.duration,
    this.visibleToPlayer = true,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String? duration;
  final bool visibleToPlayer;
}

class MonsterTemplate {
  const MonsterTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.defense,
    required this.maxHp,
    required this.attack,
    required this.damage,
    required this.movement,
    required this.instinct,
    required this.special,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final int defense;
  final int maxHp;
  final String attack;
  final String damage;
  final String movement;
  final String instinct;
  final String special;
  final String description;
}

class CombatParticipant {
  const CombatParticipant({
    required this.id,
    required this.name,
    required this.type,
    required this.currentHp,
    required this.maxHp,
    required this.defense,
    required this.statuses,
    this.sourceCharacterId,
    this.damageSuggestion,
    this.defeatedState = DefeatedState.active,
  });

  final String id;
  final String name;
  final ParticipantType type;
  final int currentHp;
  final int maxHp;
  final int defense;
  final List<StatusEntry> statuses;
  final String? sourceCharacterId;
  final String? damageSuggestion;
  final DefeatedState defeatedState;

  CombatParticipant copyWith({
    String? name,
    ParticipantType? type,
    int? currentHp,
    int? maxHp,
    int? defense,
    List<StatusEntry>? statuses,
    Object? sourceCharacterId = _unset,
    String? damageSuggestion,
    DefeatedState? defeatedState,
  }) {
    return CombatParticipant(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      defense: defense ?? this.defense,
      statuses: statuses ?? this.statuses,
      sourceCharacterId: identical(sourceCharacterId, _unset)
          ? this.sourceCharacterId
          : sourceCharacterId as String?,
      damageSuggestion: damageSuggestion ?? this.damageSuggestion,
      defeatedState: defeatedState ?? this.defeatedState,
    );
  }
}

class CombatState {
  const CombatState({
    required this.id,
    required this.active,
    required this.round,
    required this.participants,
  });

  final String id;
  final bool active;
  final int round;
  final List<CombatParticipant> participants;

  CombatState copyWith({
    bool? active,
    int? round,
    List<CombatParticipant>? participants,
  }) {
    return CombatState(
      id: id,
      active: active ?? this.active,
      round: round ?? this.round,
      participants: participants ?? this.participants,
    );
  }
}
