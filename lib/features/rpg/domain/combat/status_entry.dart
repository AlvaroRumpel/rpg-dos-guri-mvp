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
