import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/features/dashboard/domain/entities/daily_score_entity.dart';
import 'package:app/features/dashboard/domain/repositories/daily_score_repository.dart';

/// Firebase implementation of [DailyScoreRepository].
class FirebaseDailyScoreRepository implements DailyScoreRepository {
  final FirebaseFirestore _firestore;

  FirebaseDailyScoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('daily_scores');

  @override
  Stream<List<DailyScoreEntity>> watchDailyScores(String userId, int limit) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => _fromFirestore(d)).toList());
  }

  @override
  Future<void> saveDailyScore(DailyScoreEntity score) async {
    await _ref.doc(score.id).set(_toFirestore(score));
  }

  @override
  Future<DailyScoreEntity?> getTodayScore(String userId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _ref
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<DailyScoreEntity>> getWeeklyScores(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final snapshot = await _ref
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .orderBy('date', descending: false)
        .get();
    return snapshot.docs.map((d) => _fromFirestore(d)).toList();
  }

  DailyScoreEntity _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DailyScoreEntity(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      productivityScore: (data['productivityScore'] as num).toDouble(),
      growthScore: (data['growthScore'] as num).toDouble(),
      healthScore: (data['healthScore'] as num).toDouble(),
      overallScore: (data['overallScore'] as num).toDouble(),
      tasksCompleted: data['tasksCompleted'] as int? ?? 0,
      highImpactTasksCompleted: data['highImpactTasksCompleted'] as int? ?? 0,
      deepWorkMinutes: data['deepWorkMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _toFirestore(DailyScoreEntity s) {
    return {
      'userId': s.userId,
      'date': Timestamp.fromDate(s.date),
      'productivityScore': s.productivityScore,
      'growthScore': s.growthScore,
      'healthScore': s.healthScore,
      'overallScore': s.overallScore,
      'tasksCompleted': s.tasksCompleted,
      'highImpactTasksCompleted': s.highImpactTasksCompleted,
      'deepWorkMinutes': s.deepWorkMinutes,
    };
  }
}
