import 'dart:math';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';

/// Calculate Productivity Score.
///
/// Formula: (completedHighImpactTasks × 5) + (deepWorkMinutes / 30)
/// Capped at 100.
class CalculateProductivityScore {
  double call(List<TaskEntity> completedTasks) {
    final highImpactCount = completedTasks.where((t) => t.isHighImpact).length;
    final totalDeepWorkMinutes = completedTasks.fold<int>(
      0,
      (sum, t) => sum + t.deepWorkMinutes,
    );

    final raw =
        (highImpactCount * AppConstants.highImpactTaskWeight) +
        (totalDeepWorkMinutes / AppConstants.deepWorkDivisor);

    return min(raw.toDouble(), AppConstants.maxScore);
  }
}
