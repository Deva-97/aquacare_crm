import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/approval_notification_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthController extends GetxController {
  AuthController(
    this._getCurrentUser,
    this._watchCurrentUser,
    this._refreshCurrentUser,
    this._signInWithGoogle,
    this._signOut,
    this._approvalNotificationService,
  );

  final GetCurrentUserUseCase _getCurrentUser;
  final WatchCurrentUserUseCase _watchCurrentUser;
  final RefreshCurrentUserUseCase _refreshCurrentUser;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final ApprovalNotificationService _approvalNotificationService;

  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  StreamSubscription<AppUser?>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeSession();
  }

  Future<void> initializeSession() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final AppUser? localUser = await _getCurrentUser.call();
      currentUser.value = localUser;
      currentUser.value = await _refreshCurrentUser.call() ?? localUser;
      _approvalNotificationService.bindCurrentUser(currentUser.value);
      _bindCurrentUserStream();
      _routeForUser(currentUser.value);
    } catch (error) {
      errorMessage.value = error.toString();
      _approvalNotificationService.bindCurrentUser(null);
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final AppUser user = await _signInWithGoogle.call();
      currentUser.value = user;
      _approvalNotificationService.bindCurrentUser(user);
      _bindCurrentUserStream();
      _routeForUser(user);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUser() async {
    currentUser.value = await _refreshCurrentUser.call();
    _approvalNotificationService.bindCurrentUser(currentUser.value);
    _bindCurrentUserStream();
    _routeForUser(currentUser.value);
  }

  Future<void> confirmSignOut() async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await signOut();
    }
  }

  Future<void> signOut() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    await _signOut.call();
    currentUser.value = null;
    _approvalNotificationService.bindCurrentUser(null);
    Get.offAllNamed(AppRoutes.login);
  }

  void _bindCurrentUserStream() {
    _userSubscription?.cancel();
    _userSubscription = _watchCurrentUser.call().listen((AppUser? user) {
      if (user == null) {
        return;
      }
      currentUser.value = user;
      _approvalNotificationService.bindCurrentUser(user);
      _routeForUser(user);
    });
  }

  void _routeForUser(AppUser? user) {
    final String targetRoute = _targetRouteForUser(user);

    if (user?.status == AppConstants.blockedStatus) {
      errorMessage.value = 'Your account is blocked. Contact an owner.';
    }

    if (!_isCurrentRouteAllowedForUser(user, Get.currentRoute)) {
      Get.offAllNamed(targetRoute);
    }
  }

  String _targetRouteForUser(AppUser? user) {
    if (user == null) {
      return AppRoutes.login;
    }
    if (user.status == AppConstants.blockedStatus) {
      return AppRoutes.waitingApproval;
    }
    if (!user.isApproved || user.role == AppConstants.pendingRole) {
      return AppRoutes.waitingApproval;
    }
    if (user.isOwner) {
      return AppRoutes.ownerDashboard;
    }
    if (user.isEmployee) {
      return AppRoutes.employeeDashboard;
    }
    return AppRoutes.technicianDashboard;
  }

  bool _isCurrentRouteAllowedForUser(AppUser? user, String currentRoute) {
    if (currentRoute.isEmpty) {
      return false;
    }

    if (user == null) {
      return currentRoute == AppRoutes.login;
    }

    if (user.status == AppConstants.blockedStatus ||
        !user.isApproved ||
        user.role == AppConstants.pendingRole) {
      return currentRoute == AppRoutes.waitingApproval;
    }

    final Set<String> allowedRoutes = user.isOwner
        ? <String>{
            AppRoutes.ownerDashboard,
            AppRoutes.customers,
            AppRoutes.customerForm,
            AppRoutes.customerDetail,
            AppRoutes.installations,
            AppRoutes.installationForm,
            AppRoutes.services,
            AppRoutes.serviceForm,
            AppRoutes.serviceDetail,
            AppRoutes.userManagement,
            AppRoutes.auditLogs,
            AppRoutes.settings,
          }
        : user.isEmployee
        ? <String>{
            AppRoutes.employeeDashboard,
            AppRoutes.customers,
            AppRoutes.customerForm,
            AppRoutes.customerDetail,
            AppRoutes.installations,
            AppRoutes.installationForm,
          }
        : <String>{
            AppRoutes.technicianDashboard,
            AppRoutes.services,
            AppRoutes.serviceDetail,
          };

    return allowedRoutes.contains(currentRoute);
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}
