import '../../../users/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> watchCurrentUser();
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<AppUser?> refreshCurrentUser();
}
