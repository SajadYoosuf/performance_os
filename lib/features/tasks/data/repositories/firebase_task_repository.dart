import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/domain/repositories/task_repository.dart';
import 'package:app/shared/models/enums.dart';

/// Firebase implementation of [TaskRepository].
class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;

  FirebaseTaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection('tasks');

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<List<TaskEntity>> watchCompletedTasks(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    await _tasksRef.doc(task.id).set(_toFirestore(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _tasksRef.doc(task.id).update(_toFirestore(task));
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  @override
  Future<List<TaskEntity>> getCompletedTasksByDomain(
    String userId,
    String domain,
  ) async {
    final snapshot = await _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .where('domain', isEqualTo: domain)
        .get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  @override
  Future<List<TaskEntity>> getOverdueTasks(String userId) async {
    final snapshot = await _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .where('dueDate', isLessThan: Timestamp.now())
        .get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  @override
  Future<List<TaskEntity>> getHighImpactPendingTasks(String userId) async {
    final snapshot = await _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .where('impactScore', isGreaterThanOrEqualTo: 7.0)
        .get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  // ── Mapping ──

  TaskEntity _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskEntity(
      id: doc.id,
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
      isCompleted: data['isCompleted'] as bool? ?? false,
      deepWorkMinutes: data['deepWorkMinutes'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _toFirestore(TaskEntity task) {
    return {
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'domain': task.domain.name,
      'impactScore': task.impactScore,
      'urgency': task.urgency.name,
      'energyRequired': task.energyRequired.name,
      'estimatedMinutes': task.estimatedMinutes,
      'outcomeType': task.outcomeType.name,
      'isCompleted': task.isCompleted,
      'deepWorkMinutes': task.deepWorkMinutes,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'dueDate': task.dueDate != null
          ? Timestamp.fromDate(task.dueDate!)
          : null,
      'completedAt': task.completedAt != null
          ? Timestamp.fromDate(task.completedAt!)
          : null,
    };
  }
}
