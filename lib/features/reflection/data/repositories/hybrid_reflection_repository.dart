import 'dart:async';
import 'package:app/features/reflection/domain/entities/reflection_entity.dart';
import 'package:app/features/reflection/domain/repositories/reflection_repository.dart';
import 'package:app/features/reflection/data/repositories/local_reflection_repository.dart';
import 'package:app/features/reflection/data/repositories/firebase_reflection_repository.dart';

/// Hybrid repository: local-first reads with Firebase background sync.
class HybridReflectionRepository implements ReflectionRepository {
  final LocalReflectionRepository _local;
  final FirebaseReflectionRepository _remote;

  HybridReflectionRepository({
    required LocalReflectionRepository local,
    required FirebaseReflectionRepository remote,
  }) : _local = local,
       _remote = remote;

  @override
  Stream<List<ReflectionEntity>> watchReflections(String userId) {
    return _local.watchReflections(userId);
  }

  @override
  Future<void> saveReflection(ReflectionEntity reflection) async {
    await _local.saveReflection(reflection);
    _remote.saveReflection(reflection).catchError((_) {});
  }

  @override
  Future<ReflectionEntity?> getReflectionByDate(String userId, DateTime date) {
    return _local.getReflectionByDate(userId, date);
  }

  @override
  Future<List<ReflectionEntity>> getRecentReflections(
    String userId,
    int limit,
  ) {
    return _local.getRecentReflections(userId, limit);
  }
}
