import '../character/power_entry.dart';
import '../shared/rpg_enums.dart';

class RaceTemplate {
  const RaceTemplate({
    required this.id,
    required this.name,
    required this.identity,
    required this.powerName,
    required this.powerDescription,
    required this.powerEffect,
    required this.usageLimit,
    this.origin,
    this.actionCost,
    this.range,
    this.duration,
    this.roll,
    this.damage,
    this.healing,
    this.extraEffect,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String identity;
  final String powerName;
  final String powerDescription;
  final String powerEffect;
  final UsageLimit usageLimit;
  final String? origin;
  final String? actionCost;
  final String? range;
  final String? duration;
  final String? roll;
  final String? damage;
  final String? healing;
  final String? extraEffect;
  final String? notes;
  final String? source;

  PowerEntry toPowerEntry() {
    return PowerEntry(
      id: '$id-racial-${DateTime.now().microsecondsSinceEpoch}',
      name: powerName,
      type: 'Poder racial',
      description: powerDescription,
      suggestedTest: 'Conforme situacao',
      effect: powerEffect,
      usageLimit: usageLimit,
      origin: origin ?? 'Raça: $name',
      actionCost: actionCost,
      range: range,
      duration: duration,
      roll: roll,
      damage: damage,
      healing: healing,
      extraEffect: extraEffect,
      notes: notes,
      source: source,
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
    this.description,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String role;
  final List<String> skills;
  final String initialPowerName;
  final String? description;
  final String? notes;
  final String? source;
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
    this.origin,
    this.usageLimit,
    this.actionCost,
    this.range,
    this.duration,
    this.roll,
    this.effect,
    this.howItWorks,
    this.history,
    this.appearance,
    this.notes,
    this.source,
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
  final String? origin;
  final UsageLimit? usageLimit;
  final String? actionCost;
  final String? range;
  final String? duration;
  final String? roll;
  final String? effect;
  final String? howItWorks;
  final String? history;
  final String? appearance;
  final String? notes;
  final String? source;
}

class RitualTemplate {
  const RitualTemplate({
    required this.id,
    required this.name,
    required this.suggestedRoll,
    required this.description,
    required this.difficulty,
    this.origin,
    this.actionCost,
    this.range,
    this.duration,
    this.effect,
    this.extraEffect,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String suggestedRoll;
  final String description;
  final String difficulty;
  final String? origin;
  final String? actionCost;
  final String? range;
  final String? duration;
  final String? effect;
  final String? extraEffect;
  final String? notes;
  final String? source;
}

class StarterKitTemplate {
  const StarterKitTemplate({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.items,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String characterClass;
  final List<String> items;
  final String? notes;
  final String? source;
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
    this.behavior,
    this.encounterUse,
    this.rewards,
    this.howItWorks,
    this.history,
    this.appearance,
    this.notes,
    this.source,
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
  final String? behavior;
  final String? encounterUse;
  final String? rewards;
  final String? howItWorks;
  final String? history;
  final String? appearance;
  final String? notes;
  final String? source;
}
