import 'dart:async';
import 'package:app/features/dashboard/domain/entities/daily_score_entity.dart';
import 'package:app/features/dashboard/domain/repositories/daily_score_repository.dart';
import 'package:app/features/dashboard/data/repositories/local_daily_score_repository.dart';
import 'package:app/features/dashboard/data/repositories/firebase_daily_score_repository.dart';

/// Hybrid repository: local-first reads with Firebase background sync.
class HybridDailyScoreRepository implements DailyScoreRepository {
  final LocalDailyScoreRepository _local;
  final FirebaseDailyScoreRepository _remote;

  HybridDailyScoreRepository({
    required LocalDailyScoreRepository local,
    required FirebaseDailyScoreRepository remote,
  }) : _local = local,
       _remote = remote;

  @override
  Stream<List<DailyScoreEntity>> watchDailyScores(String userId, int limit) {
    return _local.watchDailyScores(userId, limit);
  }

  @override
  Future<void> saveDailyScore(DailyScoreEntity score) async {
    await _local.saveDailyScore(score);
    _remote.saveDailyScore(score).catchError((_) {});
  }

  @override
  Future<DailyScoreEntity?> getTodayScore(String userId) {
    return _local.getTodayScore(userId);
  }

  @override
  Future<List<DailyScoreEntity>> getWeeklyScores(String userId) {
    return _local.getWeeklyScores(userId);
  }
}
