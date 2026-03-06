import 'dart:async';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/domain/repositories/task_repository.dart';
import 'package:app/features/tasks/data/repositories/local_task_repository.dart';
import 'package:app/features/tasks/data/repositories/firebase_task_repository.dart';

/// Hybrid repository: writes to both local (Hive) and Firebase.
///
/// Reads come from local for instant display. Firebase writes happen
/// in the background. On first load, Firebase data is fetched and
/// merged into local storage so web and mobile stay in sync.
class HybridTaskRepository implements TaskRepository {
  final LocalTaskRepository _local;
  final FirebaseTaskRepository _remote;

  HybridTaskRepository({
    required LocalTaskRepository local,
    required FirebaseTaskRepository remote,
  }) : _local = local,
       _remote = remote;

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    // Start local stream immediately for instant UI.
    final localStream = _local.watchTasks(userId);

    // Also fetch from Firebase and merge in the background.
    _syncFromRemote(userId);

    return localStream;
  }

  @override
  Stream<List<TaskEntity>> watchCompletedTasks(String userId) {
    return _local.watchCompletedTasks(userId);
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    // Write local first (instant).
    await _local.addTask(task);
    // Write to Firebase in background.
    _remote.addTask(task).catchError((_) {});
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _local.updateTask(task);
    _remote.updateTask(task).catchError((_) {});
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _local.deleteTask(taskId);
    _remote.deleteTask(taskId).catchError((_) {});
  }

  @override
  Future<List<TaskEntity>> getCompletedTasksByDomain(
    String userId,
    String domain,
  ) {
    return _local.getCompletedTasksByDomain(userId, domain);
  }

  @override
  Future<List<TaskEntity>> getOverdueTasks(String userId) {
    return _local.getOverdueTasks(userId);
  }

  @override
  Future<List<TaskEntity>> getHighImpactPendingTasks(String userId) {
    return _local.getHighImpactPendingTasks(userId);
  }

  /// Pull tasks from Firebase and merge into local cache.
  Future<void> _syncFromRemote(String userId) async {
    try {
      // Listen to the first snapshot from Firebase.
      final remoteStream = _remote.watchTasks(userId);
      final remoteTasks = await remoteStream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => <TaskEntity>[],
      );

      // Also get completed tasks.
      final remoteCompletedStream = _remote.watchCompletedTasks(userId);
      final remoteCompleted = await remoteCompletedStream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => <TaskEntity>[],
      );

      final allRemote = [...remoteTasks, ...remoteCompleted];
      if (allRemote.isEmpty) return;

      // Merge: add remote tasks that don't exist locally.
      final localTasks = _local.allTasks;
      final localIds = localTasks.map((t) => t.id).toSet();

      for (final task in allRemote) {
        if (!localIds.contains(task.id)) {
          await _local.addTask(task);
        }
      }
    } catch (_) {
      // Sync failure is non-fatal; local data is the primary source.
    }
  }
}
