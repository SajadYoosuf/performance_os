import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/domain/repositories/task_repository.dart';
import 'package:app/shared/models/enums.dart';
import 'package:uuid/uuid.dart';

/// Task state provider.
class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  StreamSubscription<List<TaskEntity>>? _subscription;

  TaskProvider(this._repository);

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _completedTasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskEntity> get tasks => _tasks;
  List<TaskEntity> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Pending high-impact tasks.
  List<TaskEntity> get highImpactPending =>
      _tasks.where((t) => t.isHighImpact && !t.isCompleted).toList();

  /// Overdue tasks.
  List<TaskEntity> get overdueTasks =>
      _tasks.where((t) => t.isOverdue).toList();

  /// AI-prioritized task (highest impact, matching energy level).
  TaskEntity? getPriorityTask(EnergyLevel currentEnergy) {
    final candidates = List<TaskEntity>.from(_tasks);
    candidates.sort((a, b) => b.impactScore.compareTo(a.impactScore));

    if (currentEnergy == EnergyLevel.low) {
      final lowEnergy = candidates
          .where((t) => t.energyRequired == EnergyLevel.low)
          .toList();
      return lowEnergy.isNotEmpty ? lowEnergy.first : candidates.firstOrNull;
    }

    return candidates.firstOrNull;
  }

  /// Low-energy tasks for recovery mode.
  List<TaskEntity> get lowEnergyTasks =>
      _tasks.where((t) => t.energyRequired == EnergyLevel.low).toList();

  /// Start watching tasks for a user.
  void watchTasks(String userId) {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _repository
        .watchTasks(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Add a new task.
  Future<void> addTask({
    required String userId,
    required String title,
    String? description,
    required TaskDomain domain,
    required double impactScore,
    required TaskUrgency urgency,
    required EnergyLevel energyRequired,
    int estimatedMinutes = 45,
    OutcomeType outcomeType = OutcomeType.systemImprovement,
    DateTime? dueDate,
  }) async {
    _setLoading(true);
    try {
      final task = TaskEntity(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        description: description,
        domain: domain,
        impactScore: impactScore,
        urgency: urgency,
        energyRequired: energyRequired,
        estimatedMinutes: estimatedMinutes,
        outcomeType: outcomeType,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );
      await _repository.addTask(task);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Complete a task.
  Future<void> completeTask(TaskEntity task) async {
    try {
      final updated = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _repository.updateTask(updated);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a task.
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
