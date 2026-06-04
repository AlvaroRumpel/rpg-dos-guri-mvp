class CustomNpc {
  const CustomNpc({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.race = '',
    this.occupation = '',
    this.appearance = '',
    this.description = '',
    this.personality = '',
    this.goal = '',
    this.storyHook = '',
    this.notes = '',
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String race;
  final String occupation;
  final String appearance;
  final String description;
  final String personality;
  final String goal;
  final String storyHook;
  final String notes;

  CustomNpc copyWith({
    DateTime? updatedAt,
    String? name,
    String? race,
    String? occupation,
    String? appearance,
    String? description,
    String? personality,
    String? goal,
    String? storyHook,
    String? notes,
  }) {
    return CustomNpc(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      race: race ?? this.race,
      occupation: occupation ?? this.occupation,
      appearance: appearance ?? this.appearance,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      goal: goal ?? this.goal,
      storyHook: storyHook ?? this.storyHook,
      notes: notes ?? this.notes,
    );
  }
}
