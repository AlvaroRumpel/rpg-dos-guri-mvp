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
    this.origin,
    this.actionCost,
    this.range,
    this.duration,
    this.extraEffect,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String type;
  final int quantity;
  final String description;
  final String? roll;
  final int fixedBonus;
  final String? effectKind;
  final String? origin;
  final String? actionCost;
  final String? range;
  final String? duration;
  final String? extraEffect;
  final String? notes;
  final String? source;

  InventoryItem copyWith({
    String? name,
    String? type,
    int? quantity,
    String? description,
    String? roll,
    int? fixedBonus,
    String? effectKind,
    String? origin,
    String? actionCost,
    String? range,
    String? duration,
    String? extraEffect,
    String? notes,
    String? source,
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
      origin: origin ?? this.origin,
      actionCost: actionCost ?? this.actionCost,
      range: range ?? this.range,
      duration: duration ?? this.duration,
      extraEffect: extraEffect ?? this.extraEffect,
      notes: notes ?? this.notes,
      source: source ?? this.source,
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
    this.origin,
    this.actionCost,
    this.range,
    this.duration,
    this.extraEffect,
    this.notes,
    this.source,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final int defaultQuantity;
  final String? roll;
  final int fixedBonus;
  final String? effectKind;
  final String? origin;
  final String? actionCost;
  final String? range;
  final String? duration;
  final String? extraEffect;
  final String? notes;
  final String? source;

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
      origin: origin,
      actionCost: actionCost,
      range: range,
      duration: duration,
      extraEffect: extraEffect,
      notes: notes,
      source: source,
    );
  }
}
