import 'package:equatable/equatable.dart';
import 'package:app/shared/models/enums.dart';

/// Reflection entity for daily journaling entries.
class ReflectionEntity extends Equatable {
  final String id;
  final String userId;
  final String content;
  final MoodType mood;
  final double distractionHours;
  final DateTime date;
  final DateTime createdAt;

  // AI-generated analysis (populated after saving)
  final String? whatWentWell;
  final String? whatToImprove;
  final String? tomorrowSuggestion;

  const ReflectionEntity({
    required this.id,
    required this.userId,
    required this.content,
    required this.mood,
    this.distractionHours = 0.0,
    required this.date,
    required this.createdAt,
    this.whatWentWell,
    this.whatToImprove,
    this.tomorrowSuggestion,
  });

  @override
  List<Object?> get props => [id, userId, date];
}
