import 'package:flutter/material.dart';
import 'package:app/features/reflection/domain/entities/reflection_entity.dart';
import 'package:app/features/reflection/domain/repositories/reflection_repository.dart';
import 'package:app/shared/models/enums.dart';
import 'package:uuid/uuid.dart';

/// Reflection state provider.
class ReflectionProvider extends ChangeNotifier {
  final ReflectionRepository _repository;

  ReflectionProvider(this._repository);

  List<ReflectionEntity> _reflections = [];
  bool _isLoading = false;
  String? _error;

  List<ReflectionEntity> get reflections => _reflections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void watchReflections(String userId) {
    _isLoading = true;
    notifyListeners();

    _repository
        .watchReflections(userId)
        .listen(
          (reflections) {
            _reflections = reflections;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> saveReflection({
    required String userId,
    required String content,
    required MoodType mood,
    double distractionHours = 0.0,
  }) async {
    _setLoading(true);
    try {
      final reflection = ReflectionEntity(
        id: const Uuid().v4(),
        userId: userId,
        content: content,
        mood: mood,
        distractionHours: distractionHours,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _repository.saveReflection(reflection);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
