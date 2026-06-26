import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;

  @override
  Future<List<AppUser>> getPendingUsers() async {
    final List<AppUser> users = await getUsers();
    return users.where((AppUser user) {
      return user.status == AppConstants.pendingStatus ||
          user.role == AppConstants.pendingRole;
    }).toList()
      ..sort((AppUser a, AppUser b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<AppUser?> getUserById(String uid) async {
    final Map<String, dynamic>? data = await _remote.getUser(uid);
    if (data == null) return null;
    return AppUser.fromMap(data);
  }

  @override
  Future<List<AppUser>> getUsers() async {
    final List<Map<String, dynamic>> data = await _remote.getUsers();
    final List<AppUser> users = data.map(AppUser.fromMap).toList();
    users.sort((AppUser a, AppUser b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return users;
  }

  @override
  Future<void> approveUser({
    required AppUser targetUser,
    required String role,
    required String approverId,
  }) async {
    final AppUser updated = targetUser.copyWith(
      role: role,
      status: AppConstants.approvedStatus,
      approvedBy: approverId,
      updatedAt: DateTime.now(),
    );
    await updateUser(updated, actorId: approverId);
  }

  @override
  Future<void> updateUser(AppUser user, {String? actorId}) async {
    final AppUser prepared = user.copyWith(updatedAt: DateTime.now());
    await _remote.setUser(prepared.uid, prepared.toMap());
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyCustomersChanged();
    }
  }
}
