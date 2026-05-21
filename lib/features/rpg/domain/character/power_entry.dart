import '../shared/rpg_enums.dart';

class PowerEntry {
  const PowerEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.suggestedTest,
    required this.effect,
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
    this.used = false,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final String suggestedTest;
  final String effect;
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
      origin: origin,
      actionCost: actionCost,
      range: range,
      duration: duration,
      roll: roll,
      damage: damage,
      healing: healing,
      extraEffect: extraEffect,
      notes: notes,
      source: source,
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
  final String type;
  final String description;
  final String suggestedTest;
  final String effect;
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

  PowerEntry toEntry() {
    return PowerEntry(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: type,
      description: description,
      suggestedTest: suggestedTest,
      effect: effect,
      usageLimit: usageLimit,
      origin: origin,
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

class SpellTemplate {
  const SpellTemplate({
    required this.id,
    required this.name,
    required this.tier,
    required this.description,
    required this.suggestedTest,
    required this.effect,
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
  final String tier;
  final String description;
  final String suggestedTest;
  final String effect;
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

  PowerEntry toEntry() {
    return PowerEntry(
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: tier,
      description: description,
      suggestedTest: suggestedTest,
      effect: effect,
      usageLimit: usageLimit,
      origin: origin,
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

class ClassProgressionEntry {
  const ClassProgressionEntry({
    required this.id,
    required this.characterClass,
    required this.level,
    required this.name,
    required this.description,
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
  final String characterClass;
  final int level;
  final String name;
  final String description;
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
      id: '$id-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: 'Habilidade de classe',
      description: description,
      suggestedTest: 'Conforme situacao',
      effect: description,
      usageLimit: usageLimit,
      origin: origin ?? '$characterClass nivel $level',
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
