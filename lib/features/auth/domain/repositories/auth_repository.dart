import 'package:app/features/auth/domain/entities/user_entity.dart';

/// Abstract authentication repository.
abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> authStateChanges();
  Future<void> updateUserProfile(UserEntity user);
}
