class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}