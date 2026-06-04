class StoryPoint {
  const StoryPoint({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.body,
    required this.order,
    this.status = 'ideia',
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String body;
  final int order;
  final String status;

  StoryPoint copyWith({
    DateTime? updatedAt,
    String? title,
    String? body,
    int? order,
    String? status,
  }) {
    return StoryPoint(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      body: body ?? this.body,
      order: order ?? this.order,
      status: status ?? this.status,
    );
  }
}
