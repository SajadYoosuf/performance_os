import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapUser(credential.user!);
  }

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);

    final user = UserEntity(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'email': email,
      'primaryDomains': ['work'],
      'dailyFocusHours': 6,
      'peakEnergyTime': 'morning',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': user.displayName,
      'primaryDomains': user.primaryDomains,
      'dailyFocusHours': user.dailyFocusHours,
      'peakEnergyTime': user.peakEnergyTime,
    });
  }

  UserEntity _mapUser(User user) {
    return UserEntity(
      uid: user.uid,
      displayName: user.displayName ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
