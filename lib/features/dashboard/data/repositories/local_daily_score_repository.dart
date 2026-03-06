import 'dart:async';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/features/dashboard/domain/entities/daily_score_entity.dart';
import 'package:app/features/dashboard/domain/repositories/daily_score_repository.dart';

/// Local (Hive) implementation of [DailyScoreRepository].
class LocalDailyScoreRepository implements DailyScoreRepository {
  final LocalStorageService _storage;

  List<DailyScoreEntity> _cache = [];
  String? _currentUserId;
  final _controller = StreamController<List<DailyScoreEntity>>.broadcast();

  LocalDailyScoreRepository(this._storage);

  String _key(String userId) => 'daily_scores_$userId';

  void _loadFromDisk(String userId) {
    final data = _storage.getJsonList(_storage.scoresBox, _key(userId));
    _cache = data.map((m) => _fromMap(m)).toList();
    _currentUserId = userId;
  }

  Future<void> _saveToDisk() async {
    if (_currentUserId == null) return;
    await _storage.saveJsonList(
      _storage.scoresBox,
      _key(_currentUserId!),
      _cache.map((s) => _toMap(s)).toList(),
    );
  }

  @override
  Stream<List<DailyScoreEntity>> watchDailyScores(String userId, int limit) {
    _loadFromDisk(userId);
    Future.microtask(() {
      final sorted = List<DailyScoreEntity>.from(_cache)
        ..sort((a, b) => b.date.compareTo(a.date));
      _controller.add(sorted.take(limit).toList());
    });
    return _controller.stream;
  }

  @override
  Future<void> saveDailyScore(DailyScoreEntity score) async {
    final idx = _cache.indexWhere((s) => s.id == score.id);
    if (idx != -1) {
      _cache[idx] = score;
    } else {
      _cache.add(score);
    }
    await _saveToDisk();
    final sorted = List<DailyScoreEntity>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    _controller.add(sorted);
  }

  @override
  Future<DailyScoreEntity?> getTodayScore(String userId) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    try {
      return _cache.firstWhere(
        (s) => s.date.isAfter(start) && s.date.isBefore(end),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DailyScoreEntity>> getWeeklyScores(String userId) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _cache.where((s) => s.date.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // ── JSON mapping ──

  DailyScoreEntity _fromMap(Map<String, dynamic> data) {
    return DailyScoreEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      date: DateTime.parse(data['date'] as String),
      productivityScore: (data['productivityScore'] as num).toDouble(),
      growthScore: (data['growthScore'] as num).toDouble(),
      healthScore: (data['healthScore'] as num).toDouble(),
      overallScore: (data['overallScore'] as num).toDouble(),
      tasksCompleted: data['tasksCompleted'] as int? ?? 0,
      highImpactTasksCompleted: data['highImpactTasksCompleted'] as int? ?? 0,
      deepWorkMinutes: data['deepWorkMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _toMap(DailyScoreEntity s) {
    return {
      'id': s.id,
      'userId': s.userId,
      'date': s.date.toIso8601String(),
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
