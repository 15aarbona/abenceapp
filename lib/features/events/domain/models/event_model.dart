class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String? imageUrl;
  final bool isActive;
  final Map<String, dynamic>? options; // Para menús, etc.

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    this.imageUrl,
    required this.isActive,
    this.options,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']), // Supabase devuelve ISO string
      location: json['location'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      options: json['options'],
    );
  }
}