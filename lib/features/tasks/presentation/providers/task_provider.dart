import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/domain/repositories/task_repository.dart';
import 'package:app/shared/models/enums.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Task state provider with time-based views and context summary.
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

  // ── Existing filtered views ──

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
      final lowEnergy =
          candidates.where((t) => t.energyRequired == EnergyLevel.low).toList();
      return lowEnergy.isNotEmpty ? lowEnergy.first : candidates.firstOrNull;
    }

    return candidates.firstOrNull;
  }

  /// Low-energy tasks for recovery mode.
  List<TaskEntity> get lowEnergyTasks =>
      _tasks.where((t) => t.energyRequired == EnergyLevel.low).toList();

  // ── Time-based views ──

  /// All tasks (pending) created or due today.
  List<TaskEntity> get todayTasks {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _tasks.where((t) {
      // If task has a start date, it only shows on/after that date
      if (t.startDate != null) {
        return t.startDate!.isBefore(endOfDay);
      }
      // Fallback to createdAt if no startDate
      final isCreatedToday =
          t.createdAt.isAfter(startOfDay) && t.createdAt.isBefore(endOfDay);
      final isDueToday =
          t.dueDate != null &&
          t.dueDate!.isAfter(startOfDay) &&
          t.dueDate!.isBefore(endOfDay);
      return isCreatedToday || isDueToday;
    }).toList();
  }

  /// All tasks (pending) created or due this week.
  List<TaskEntity> get thisWeekTasks {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final end = start.add(const Duration(days: 7));
    return _tasks.where((t) {
      final inRange = t.createdAt.isAfter(start) && t.createdAt.isBefore(end);
      final dueInRange =
          t.dueDate != null &&
          t.dueDate!.isAfter(start) &&
          t.dueDate!.isBefore(end);
      return inRange || dueInRange;
    }).toList();
  }

  /// All tasks (pending) created or due this month.
  List<TaskEntity> get thisMonthTasks {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return _tasks.where((t) {
      final inRange = t.createdAt.isAfter(start) && t.createdAt.isBefore(end);
      final dueInRange =
          t.dueDate != null &&
          t.dueDate!.isAfter(start) &&
          t.dueDate!.isBefore(end);
      return inRange || dueInRange;
    }).toList();
  }

  /// Completed tasks today.
  List<TaskEntity> get completedToday {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _completedTasks.where((t) {
      return t.completedAt != null && t.completedAt!.isAfter(startOfDay);
    }).toList();
  }

  /// Completed tasks this week.
  List<TaskEntity> get completedThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return _completedTasks.where((t) {
      return t.completedAt != null && t.completedAt!.isAfter(start);
    }).toList();
  }

  /// Completed tasks this month.
  List<TaskEntity> get completedThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _completedTasks.where((t) {
      return t.completedAt != null && t.completedAt!.isAfter(start);
    }).toList();
  }

  // ── RAG Context Builder ──

  /// Builds a structured text summary of all tasks for AI context injection.
  String buildTaskContextForAI() {
    final buf = StringBuffer();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');

    buf.writeln('=== USER TASK DATA (as of ${dateFormat.format(now)}) ===');
    buf.writeln();

    // Pending tasks summary
    buf.writeln('## PENDING TASKS (${_tasks.length} total)');
    if (_tasks.isEmpty) {
      buf.writeln('No pending tasks.');
    } else {
      for (final t in _tasks) {
        buf.write('- "${t.title}" | Domain: ${t.domain.label}');
        buf.write(' | Impact: ${t.impactScore}/10');
        buf.write(' | Urgency: ${t.urgency.label}');
        buf.write(' | Energy: ${t.energyRequired.label}');
        buf.write(' | Est: ${t.estimatedMinutes}min');
        if (t.dueDate != null) {
          buf.write(' | Due: ${dateFormat.format(t.dueDate!)}');
        }
        if (t.isOverdue) buf.write(' | ⚠️ OVERDUE');
        buf.writeln();
      }
    }
    buf.writeln();

    // Today's stats
    buf.writeln('## TODAY');
    buf.writeln('- Pending today: ${todayTasks.length}');
    buf.writeln('- Completed today: ${completedToday.length}');
    buf.writeln();

    // This week stats
    buf.writeln('## THIS WEEK');
    buf.writeln('- Pending this week: ${thisWeekTasks.length}');
    buf.writeln('- Completed this week: ${completedThisWeek.length}');
    buf.writeln();

    // This month stats
    buf.writeln('## THIS MONTH');
    buf.writeln('- Pending this month: ${thisMonthTasks.length}');
    buf.writeln('- Completed this month: ${completedThisMonth.length}');
    buf.writeln();

    // Overdue
    final overdue = overdueTasks;
    if (overdue.isNotEmpty) {
      buf.writeln('## ⚠️ OVERDUE TASKS (${overdue.length})');
      for (final t in overdue) {
        buf.writeln('- "${t.title}" — Due: ${dateFormat.format(t.dueDate!)}');
      }
      buf.writeln();
    }

    // Completed tasks (recent 10)
    final recentCompleted = _completedTasks.take(10).toList();
    if (recentCompleted.isNotEmpty) {
      buf.writeln('## RECENTLY COMPLETED (last ${recentCompleted.length})');
      for (final t in recentCompleted) {
        buf.write('- "${t.title}" | Domain: ${t.domain.label}');
        if (t.completedAt != null) {
          buf.write(' | Completed: ${dateFormat.format(t.completedAt!)}');
        }
        buf.writeln();
      }
      buf.writeln();
    }

    // Domain breakdown
    buf.writeln('## DOMAIN BREAKDOWN');
    for (final domain in TaskDomain.values) {
      final pending = _tasks.where((t) => t.domain == domain).length;
      final completed = _completedTasks.where((t) => t.domain == domain).length;
      buf.writeln('- ${domain.label}: $pending pending, $completed completed');
    }

    return buf.toString();
  }

  // ── Repository operations ──

  /// Start watching tasks for a user.
  String? _userId;
  String? get currentUserId => _userId;

  void watchTasks(String userId) {
    _userId = userId;
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

    // Also watch completed tasks.
    _repository.watchCompletedTasks(userId).listen((completed) {
      _completedTasks = completed;
      notifyListeners();
    });
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
    DateTime? startDate,
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
        startDate: startDate,
      );
      await addTaskInstance(task);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTaskInstance(TaskEntity task) async {
    await _repository.addTask(task);
  }

  /// Update an existing task.
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _repository.updateTask(task);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Complete a task.
  Future<void> completeTask(TaskEntity task) async {
    try {
      final updated = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await updateTask(updated);
      NotificationService().notifyTaskCompleted(task.title);
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
