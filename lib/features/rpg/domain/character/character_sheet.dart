import '../combat/status_entry.dart';
import 'inventory_item.dart';
import 'power_entry.dart';

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
