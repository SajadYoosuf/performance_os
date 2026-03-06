import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Core local storage service backed by Hive.
///
/// Each data domain gets its own Hive box for isolation.
/// Must be initialised via [init] before use (call in `main()`).
class LocalStorageService {
  static const _authBox = 'auth';
  static const _tasksBox = 'tasks';
  static const _scoresBox = 'daily_scores';
  static const _reflectionsBox = 'reflections';

  late final Box _auth;
  late final Box _tasks;
  late final Box _scores;
  late final Box _reflections;

  /// Initialise Hive and open all boxes. Call once in `main()`.
  Future<void> init() async {
    await Hive.initFlutter();
    _auth = await Hive.openBox(_authBox);
    _tasks = await Hive.openBox(_tasksBox);
    _scores = await Hive.openBox(_scoresBox);
    _reflections = await Hive.openBox(_reflectionsBox);
  }

  // ── Box accessors ──

  Box get authBox => _auth;
  Box get tasksBox => _tasks;
  Box get scoresBox => _scores;
  Box get reflectionsBox => _reflections;

  // ── Generic JSON helpers ──

  /// Save a list of JSON maps under [key] in [box].
  Future<void> saveJsonList(
    Box box,
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    await box.put(key, jsonEncode(data));
  }

  /// Read a JSON list from [box] under [key]. Returns `[]` if absent.
  List<Map<String, dynamic>> getJsonList(Box box, String key) {
    final raw = box.get(key) as String?;
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Save a single JSON map under [key] in [box].
  Future<void> saveJson(Box box, String key, Map<String, dynamic> data) async {
    await box.put(key, jsonEncode(data));
  }

  /// Read a single JSON map from [box] under [key].
  Map<String, dynamic>? getJson(Box box, String key) {
    final raw = box.get(key) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Remove a key from [box].
  Future<void> remove(Box box, String key) => box.delete(key);
}
