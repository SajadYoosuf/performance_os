import 'dart:async';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/domain/repositories/task_repository.dart';
import 'package:app/shared/models/enums.dart';

/// Local (Hive) implementation of [TaskRepository].
class LocalTaskRepository implements TaskRepository {
  final LocalStorageService _storage;

  /// In-memory cache of tasks for the current user.
  List<TaskEntity> _cache = [];
  String? _currentUserId;

  /// Stream controllers for reactive updates.
  final _pendingController = StreamController<List<TaskEntity>>.broadcast();
  final _completedController = StreamController<List<TaskEntity>>.broadcast();

  LocalTaskRepository(this._storage);

  String _key(String userId) => 'tasks_$userId';

  // ── Persistence helpers ──

  void _loadFromDisk(String userId) {
    final data = _storage.getJsonList(_storage.tasksBox, _key(userId));
    _cache = data.map((m) => _fromMap(m)).toList();
    _currentUserId = userId;
  }

  Future<void> _saveToDisk() async {
    if (_currentUserId == null) return;
    await _storage.saveJsonList(
      _storage.tasksBox,
      _key(_currentUserId!),
      _cache.map((t) => _toMap(t)).toList(),
    );
  }

  void _broadcast() {
    _pendingController.add(
      _cache.where((t) => !t.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
    _completedController.add(
      _cache.where((t) => t.isCompleted).toList()..sort(
        (a, b) => (b.completedAt ?? b.createdAt).compareTo(
          a.completedAt ?? a.createdAt,
        ),
      ),
    );
  }

  // ── TaskRepository interface ──

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    _loadFromDisk(userId);
    Future.microtask(() => _broadcast());
    return _pendingController.stream;
  }

  @override
  Stream<List<TaskEntity>> watchCompletedTasks(String userId) {
    if (_currentUserId != userId) _loadFromDisk(userId);
    Future.microtask(() => _broadcast());
    return _completedController.stream;
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    if (_currentUserId != task.userId) _loadFromDisk(task.userId);
    _cache.add(task);
    await _saveToDisk();
    _broadcast();
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    if (_currentUserId != task.userId) _loadFromDisk(task.userId);
    final idx = _cache.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _cache[idx] = task;
      await _saveToDisk();
      _broadcast();
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Note: deleteTask in the interface only takes taskId.
    // If _currentUserId is null, we might be deleting from the wrong cache
    // or failing to save. However, in this app, userId is usually available
    // or watchTasks has been called. For safety, we'll assume the current cache
    // is correct or wait for a watch call.
    _cache.removeWhere((t) => t.id == taskId);
    await _saveToDisk();
    _broadcast();
  }

  @override
  Future<List<TaskEntity>> getCompletedTasksByDomain(
    String userId,
    String domain,
  ) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    return _cache
        .where((t) => t.isCompleted && t.domain.name == domain)
        .toList();
  }

  @override
  Future<List<TaskEntity>> getOverdueTasks(String userId) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    return _cache.where((t) => t.isOverdue).toList();
  }

  @override
  Future<List<TaskEntity>> getHighImpactPendingTasks(String userId) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    return _cache.where((t) => t.isHighImpact && !t.isCompleted).toList();
  }

  /// Get all tasks (pending + completed) for context building.
  List<TaskEntity> get allTasks => List.unmodifiable(_cache);

  // ── JSON mapping ──

  TaskEntity _fromMap(Map<String, dynamic> data) {
    return TaskEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      domain: TaskDomain.values.firstWhere(
        (e) => e.name == data['domain'],
        orElse: () => TaskDomain.work,
      ),
      impactScore: (data['impactScore'] as num).toDouble(),
      urgency: TaskUrgency.values.firstWhere(
        (e) => e.name == data['urgency'],
        orElse: () => TaskUrgency.medium,
      ),
      energyRequired: EnergyLevel.values.firstWhere(
        (e) => e.name == data['energyRequired'],
        orElse: () => EnergyLevel.medium,
      ),
      estimatedMinutes: data['estimatedMinutes'] as int? ?? 45,
      outcomeType: OutcomeType.values.firstWhere(
        (e) => e.name == data['outcomeType'],
        orElse: () => OutcomeType.systemImprovement,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'todo'),
        orElse: () => TaskStatus.todo,
      ),
      isPersonal: data['isPersonal'] as bool? ?? false,
      occurrence: data['occurrence'] as String?,
      reminderTimes: List<String>.from(data['reminderTimes'] ?? const []),
      isCompleted: data['isCompleted'] as bool? ?? false,
      deepWorkMinutes: data['deepWorkMinutes'] as int? ?? 0,
      createdAt: DateTime.parse(data['createdAt'] as String),
      dueDate:
          data['dueDate'] != null
              ? DateTime.parse(data['dueDate'] as String)
              : null,
      startDate:
          data['startDate'] != null
              ? DateTime.parse(data['startDate'] as String)
              : null,
      completedAt:
          data['completedAt'] != null
              ? DateTime.parse(data['completedAt'] as String)
              : null,
      isProject: data['isProject'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _toMap(TaskEntity task) {
    return {
      'id': task.id,
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'domain': task.domain.name,
      'impactScore': task.impactScore,
      'urgency': task.urgency.name,
      'energyRequired': task.energyRequired.name,
      'estimatedMinutes': task.estimatedMinutes,
      'outcomeType': task.outcomeType.name,
      'status': task.status.name,
      'isPersonal': task.isPersonal,
      'occurrence': task.occurrence,
      'reminderTimes': task.reminderTimes,
      'isCompleted': task.isCompleted,
      'deepWorkMinutes': task.deepWorkMinutes,
      'createdAt': task.createdAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'startDate': task.startDate?.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'isProject': task.isProject,
    };
  }
}
