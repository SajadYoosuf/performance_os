import 'package:equatable/equatable.dart';

/// Daily performance score entity.
class DailyScoreEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double productivityScore;
  final double growthScore;
  final double healthScore;
  final double overallScore;
  final int tasksCompleted;
  final int highImpactTasksCompleted;
  final int deepWorkMinutes;

  const DailyScoreEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.productivityScore,
    required this.growthScore,
    required this.healthScore,
    required this.overallScore,
    this.tasksCompleted = 0,
    this.highImpactTasksCompleted = 0,
    this.deepWorkMinutes = 0,
  });

  @override
  List<Object?> get props => [id, userId, date];
}
