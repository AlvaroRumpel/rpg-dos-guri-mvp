class CampaignNote {
  const CampaignNote({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.body,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String body;

  CampaignNote copyWith({DateTime? updatedAt, String? title, String? body}) {
    return CampaignNote(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }
}
