import 'dart:math';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/shared/models/enums.dart';

/// Calculate Health Score.
///
/// Based on completed tasks where domain == health.
/// Normalized to 0-100 scale.
class CalculateHealthScore {
  double call(List<TaskEntity> completedTasks) {
    final healthTasks = completedTasks
        .where((t) => t.domain == TaskDomain.health)
        .toList();

    if (healthTasks.isEmpty) return 0.0;

    // Score = (health tasks completed × 12) + bonus for consistency
    final base = healthTasks.length * 12;
    final highImpactBonus = healthTasks.where((t) => t.isHighImpact).length * 5;

    return min((base + highImpactBonus).toDouble(), AppConstants.maxScore);
  }
}
