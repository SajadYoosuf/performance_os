import 'package:equatable/equatable.dart';
import 'package:app/shared/models/enums.dart';

/// Task entity — core data model for the Performance OS.
class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskDomain domain;
  final double impactScore; // 1.0 to 10.0
  final TaskUrgency urgency;
  final EnergyLevel energyRequired;
  final int estimatedMinutes;
  final OutcomeType outcomeType;
  final bool isCompleted;
  final int deepWorkMinutes;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.domain,
    required this.impactScore,
    required this.urgency,
    required this.energyRequired,
    this.estimatedMinutes = 45,
    this.outcomeType = OutcomeType.systemImprovement,
    this.isCompleted = false,
    this.deepWorkMinutes = 0,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
  });

  /// Whether this task has HIGH impact (score >= 7).
  bool get isHighImpact => impactScore >= 7.0;

  /// Whether the task is overdue.
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskDomain? domain,
    double? impactScore,
    TaskUrgency? urgency,
    EnergyLevel? energyRequired,
    int? estimatedMinutes,
    OutcomeType? outcomeType,
    bool? isCompleted,
    int? deepWorkMinutes,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      impactScore: impactScore ?? this.impactScore,
      urgency: urgency ?? this.urgency,
      energyRequired: energyRequired ?? this.energyRequired,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      outcomeType: outcomeType ?? this.outcomeType,
      isCompleted: isCompleted ?? this.isCompleted,
      deepWorkMinutes: deepWorkMinutes ?? this.deepWorkMinutes,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, isCompleted];
}
