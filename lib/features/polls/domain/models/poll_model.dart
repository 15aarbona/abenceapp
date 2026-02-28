// lib/features/polls/domain/models/poll_model.dart

// 1. Modelo para la Votación Principal
class PollModel {
  final String id;
  final String title;
  final String? description;
  final DateTime endDate;
  final bool isMultipleChoice;

  PollModel({
    required this.id,
    required this.title,
    this.description,
    required this.endDate,
    required this.isMultipleChoice,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      // Convertimos el texto de fecha de Supabase a un objeto DateTime de Dart
      endDate: DateTime.parse(json['end_date'] as String), 
      isMultipleChoice: json['is_multiple_choice'] ?? false,
    );
  }

  // Saber si la votación ya ha cerrado
  bool get isClosed => DateTime.now().isAfter(endDate);
}

// 2. Modelo para las Opciones (Ej: La Fúmiga, Zoo...)
class PollOptionModel {
  final String id;
  final String pollId;
  final String text;

  PollOptionModel({
    required this.id,
    required this.pollId,
    required this.text,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      text: json['text'] as String,
    );
  }
}

// 3. Modelo para los Votos (Quién vota qué)
class PollVoteModel {
  final String id;
  final String pollId;
  final String optionId;
  final String userId;

  PollVoteModel({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.userId,
  });

  factory PollVoteModel.fromJson(Map<String, dynamic> json) {
    return PollVoteModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionId: json['option_id'] as String,
      userId: json['user_id'] as String,
    );
  }
}