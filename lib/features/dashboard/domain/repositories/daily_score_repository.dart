import 'package:app/features/dashboard/domain/entities/daily_score_entity.dart';

/// Abstract daily score repository.
abstract class DailyScoreRepository {
  Stream<List<DailyScoreEntity>> watchDailyScores(String userId, int limit);
  Future<void> saveDailyScore(DailyScoreEntity score);
  Future<DailyScoreEntity?> getTodayScore(String userId);
  Future<List<DailyScoreEntity>> getWeeklyScores(String userId);
}
