import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/users_usecases.dart';

class UsersController extends GetxController {
  UsersController(
    this._getUsers,
    this._getPendingUsers,
    this._approveUser,
    this._updateUser,
    this._authController,
  );

  final GetUsersUseCase _getUsers;
  final GetPendingUsersUseCase _getPendingUsers;
  final ApproveUserUseCase _approveUser;
  final UpdateUserUseCase _updateUser;
  final AuthController _authController;

  final RxList<AppUser> users = <AppUser>[].obs;
  final RxList<AppUser> pendingUsers = <AppUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      users.assignAll(await _getUsers.call());
      pendingUsers.assignAll(await _getPendingUsers.call());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(AppUser user, String role) async {
    final approver = _authController.currentUser.value;
    if (approver == null) {
      return;
    }
    await _approveUser.call(
      targetUser: user,
      role: role,
      approverId: approver.uid,
    );
    await load();
  }

  Future<void> blockUser(AppUser user) async {
    final approver = _authController.currentUser.value;
    if (approver == null) {
      return;
    }
    await _updateUser.call(
      user.copyWith(status: AppConstants.blockedStatus, updatedAt: DateTime.now()),
      actorId: approver.uid,
    );
    await load();
  }

  Future<void> unblockUser(AppUser user) async {
    final approver = _authController.currentUser.value;
    if (approver == null) {
      return;
    }
    await _updateUser.call(
      user.copyWith(status: AppConstants.approvedStatus, updatedAt: DateTime.now()),
      actorId: approver.uid,
    );
    await load();
  }

  Future<void> changeRole(AppUser user, String role) async {
    final approver = _authController.currentUser.value;
    if (approver == null) {
      return;
    }
    await _updateUser.call(
      user.copyWith(role: role, updatedAt: DateTime.now()),
      actorId: approver.uid,
    );
    await load();
  }
}
