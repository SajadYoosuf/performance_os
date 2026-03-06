import 'package:flutter/material.dart';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

/// Authentication state provider with Hive-based local persistence.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final LocalStorageService _storage;

  static const _userKey = 'cached_user';

  AuthProvider(this._repository, this._storage) {
    _init();
  }

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  void _init() {
    // 1. Restore cached user immediately for instant UI.
    _restoreCachedUser();

    // 2. Listen to Firebase auth stream — overwrites cache when available.
    _repository.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _cacheUser(user);
      } else {
        _clearCachedUser();
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.signInWithEmail(email, password);
      if (_user != null) _cacheUser(_user!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    try {
      _user = await _repository.signUpWithEmail(email, password, displayName);
      if (_user != null) _cacheUser(_user!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _clearCachedUser();
    notifyListeners();
  }

  Future<void> updateProfile(UserEntity updatedUser) async {
    _setLoading(true);
    try {
      await _repository.updateUserProfile(updatedUser);
      _user = updatedUser;
      _cacheUser(updatedUser);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Hive persistence helpers ──

  void _restoreCachedUser() {
    final json = _storage.getJson(_storage.authBox, _userKey);
    if (json != null) {
      _user = UserEntity(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
        primaryDomains:
            (json['primaryDomains'] as List<dynamic>?)?.cast<String>() ??
            const ['work'],
        dailyFocusHours: json['dailyFocusHours'] as int? ?? 6,
        peakEnergyTime: json['peakEnergyTime'] as String? ?? 'morning',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
      notifyListeners();
    }
  }

  void _cacheUser(UserEntity user) {
    _storage.saveJson(_storage.authBox, _userKey, {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'primaryDomains': user.primaryDomains,
      'dailyFocusHours': user.dailyFocusHours,
      'peakEnergyTime': user.peakEnergyTime,
      'createdAt': user.createdAt.toIso8601String(),
    });
  }

  void _clearCachedUser() {
    _storage.remove(_storage.authBox, _userKey);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
