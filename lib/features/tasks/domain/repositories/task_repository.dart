import 'package:app/features/tasks/domain/entities/task_entity.dart';

/// Abstract task repository.
abstract class TaskRepository {
  Stream<List<TaskEntity>> watchTasks(String userId);
  Stream<List<TaskEntity>> watchCompletedTasks(String userId);
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskEntity>> getCompletedTasksByDomain(
    String userId,
    String domain,
  );
  Future<List<TaskEntity>> getOverdueTasks(String userId);
  Future<List<TaskEntity>> getHighImpactPendingTasks(String userId);
}
