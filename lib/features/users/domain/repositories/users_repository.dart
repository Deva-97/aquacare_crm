import '../entities/app_user.dart';

abstract class UsersRepository {
  Future<List<AppUser>> getUsers();
  Future<List<AppUser>> getPendingUsers();
  Future<AppUser?> getUserById(String uid);
  Future<void> approveUser({
    required AppUser targetUser,
    required String role,
    required String approverId,
  });
  Future<void> updateUser(AppUser user, {String? actorId});
}
