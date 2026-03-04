import 'dart:math';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/shared/models/enums.dart';

/// Calculate Growth Score.
///
/// Based on completed tasks where domain == learning.
/// Normalized to 0-100 scale.
class CalculateGrowthScore {
  double call(List<TaskEntity> completedTasks) {
    final learningTasks = completedTasks
        .where((t) => t.domain == TaskDomain.learning)
        .toList();

    if (learningTasks.isEmpty) return 0.0;

    // Score = (learning tasks completed × 10) + bonus for high-impact learning
    final base = learningTasks.length * 10;
    final highImpactBonus =
        learningTasks.where((t) => t.isHighImpact).length * 5;

    return min((base + highImpactBonus).toDouble(), AppConstants.maxScore);
  }
}
