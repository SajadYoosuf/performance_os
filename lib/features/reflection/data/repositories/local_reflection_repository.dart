import 'dart:async';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/features/reflection/domain/entities/reflection_entity.dart';
import 'package:app/features/reflection/domain/repositories/reflection_repository.dart';
import 'package:app/shared/models/enums.dart';

/// Local (Hive) implementation of [ReflectionRepository].
class LocalReflectionRepository implements ReflectionRepository {
  final LocalStorageService _storage;

  List<ReflectionEntity> _cache = [];
  String? _currentUserId;
  final _controller = StreamController<List<ReflectionEntity>>.broadcast();

  LocalReflectionRepository(this._storage);

  String _key(String userId) => 'reflections_$userId';

  void _loadFromDisk(String userId) {
    final data = _storage.getJsonList(_storage.reflectionsBox, _key(userId));
    _cache = data.map((m) => _fromMap(m)).toList();
    _currentUserId = userId;
  }

  Future<void> _saveToDisk() async {
    if (_currentUserId == null) return;
    await _storage.saveJsonList(
      _storage.reflectionsBox,
      _key(_currentUserId!),
      _cache.map((r) => _toMap(r)).toList(),
    );
  }

  void _broadcast() {
    final sorted = List<ReflectionEntity>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    _controller.add(sorted);
  }

  @override
  Stream<List<ReflectionEntity>> watchReflections(String userId) {
    _loadFromDisk(userId);
    Future.microtask(() => _broadcast());
    return _controller.stream;
  }

  @override
  Future<void> saveReflection(ReflectionEntity reflection) async {
    final idx = _cache.indexWhere((r) => r.id == reflection.id);
    if (idx != -1) {
      _cache[idx] = reflection;
    } else {
      _cache.add(reflection);
    }
    await _saveToDisk();
    _broadcast();
  }

  @override
  Future<ReflectionEntity?> getReflectionByDate(
    String userId,
    DateTime date,
  ) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    try {
      return _cache.firstWhere(
        (r) =>
            r.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            r.date.isBefore(end),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ReflectionEntity>> getRecentReflections(
    String userId,
    int limit,
  ) async {
    if (_currentUserId != userId) _loadFromDisk(userId);
    final sorted = List<ReflectionEntity>.from(_cache)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  // ── JSON mapping ──

  ReflectionEntity _fromMap(Map<String, dynamic> data) {
    return ReflectionEntity(
      id: data['id'] as String,
      userId: data['userId'] as String,
      content: data['content'] as String,
      mood: MoodType.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => MoodType.calm,
      ),
      distractionHours: (data['distractionHours'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(data['date'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      whatWentWell: data['whatWentWell'] as String?,
      whatToImprove: data['whatToImprove'] as String?,
      tomorrowSuggestion: data['tomorrowSuggestion'] as String?,
    );
  }

  Map<String, dynamic> _toMap(ReflectionEntity r) {
    return {
      'id': r.id,
      'userId': r.userId,
      'content': r.content,
      'mood': r.mood.name,
      'distractionHours': r.distractionHours,
      'date': r.date.toIso8601String(),
      'createdAt': r.createdAt.toIso8601String(),
      'whatWentWell': r.whatWentWell,
      'whatToImprove': r.whatToImprove,
      'tomorrowSuggestion': r.tomorrowSuggestion,
    };
  }
}
