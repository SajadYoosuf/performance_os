import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/features/reflection/domain/entities/reflection_entity.dart';
import 'package:app/features/reflection/domain/repositories/reflection_repository.dart';
import 'package:app/shared/models/enums.dart';

/// Firebase implementation of [ReflectionRepository].
class FirebaseReflectionRepository implements ReflectionRepository {
  final FirebaseFirestore _firestore;

  FirebaseReflectionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('reflections');

  @override
  Stream<List<ReflectionEntity>> watchReflections(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => _fromFirestore(d)).toList());
  }

  @override
  Future<void> saveReflection(ReflectionEntity reflection) async {
    await _ref.doc(reflection.id).set(_toFirestore(reflection));
  }

  @override
  Future<ReflectionEntity?> getReflectionByDate(
    String userId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
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
  Future<List<ReflectionEntity>> getRecentReflections(
    String userId,
    int limit,
  ) async {
    final snapshot = await _ref
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => _fromFirestore(d)).toList();
  }

  ReflectionEntity _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReflectionEntity(
      id: doc.id,
      userId: data['userId'] as String,
      content: data['content'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => MoodType.calm,
      ),
      distractionHours: (data['distractionHours'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      whatWentWell: data['whatWentWell'] as String?,
      whatToImprove: data['whatToImprove'] as String?,
      tomorrowSuggestion: data['tomorrowSuggestion'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(ReflectionEntity r) {
    return {
      'userId': r.userId,
      'content': r.content,
      'mood': r.mood.name,
      'distractionHours': r.distractionHours,
      'date': Timestamp.fromDate(r.date),
      'createdAt': Timestamp.fromDate(r.createdAt),
      'whatWentWell': r.whatWentWell,
      'whatToImprove': r.whatToImprove,
      'tomorrowSuggestion': r.tomorrowSuggestion,
    };
  }
}
