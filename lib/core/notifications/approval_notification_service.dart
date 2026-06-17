import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../features/users/domain/entities/app_user.dart';
import '../../features/users/domain/usecases/users_usecases.dart';
import '../../features/users/presentation/controllers/users_controller.dart';
import '../constants/app_constants.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

class ApprovalNotificationService extends GetxService with WidgetsBindingObserver {
  static const String _notificationIcon = '@mipmap/ic_launcher';

  ApprovalNotificationService(
    this._notificationsPlugin,
    this._remote,
    this._approveUser,
    this._updateUser,
  );

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FirestoreRemoteDataSource _remote;
  final ApproveUserUseCase _approveUser;
  final UpdateUserUseCase _updateUser;

  final RxInt pendingCount = 0.obs;

  final Map<String, AppUser> _pendingUsersById = <String, AppUser>{};
  final Set<String> _knownPendingIds = <String>{};

  StreamSubscription<List<Map<String, dynamic>>>? _pendingUsersSubscription;
  AppUser? _currentUser;
  bool _hasPrimedPendingUsers = false;
  bool _isAppInForeground = true;
  bool _isDialogOpen = false;
  String? _queuedApprovalUid;

  Future<ApprovalNotificationService> init() async {
    WidgetsBinding.instance.addObserver(this);

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(_notificationIcon);
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.requestNotificationsPermission();
    await androidPlatform?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.approvalNotificationChannelId,
        AppConstants.approvalNotificationChannelName,
        description: AppConstants.approvalNotificationChannelDescription,
        importance: Importance.high,
      ),
    );

    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
    if (_isAppInForeground) {
      _openQueuedDialogIfPossible();
    }
  }

  void bindCurrentUser(AppUser? user) {
    _currentUser = user;
    if (user?.isOwner ?? false) {
      _startOwnerPendingUserListener();
      return;
    }
    _stopOwnerPendingUserListener();
  }

  Future<void> openNextPendingApproval() async {
    if (_pendingUsersById.isEmpty) {
      Get.snackbar('No pending approvals', 'There are no users waiting for approval right now.');
      return;
    }

    final List<AppUser> sortedUsers = _pendingUsersById.values.toList()
      ..sort((AppUser a, AppUser b) => a.createdAt.compareTo(b.createdAt));
    await showApprovalDialog(sortedUsers.first);
  }

  Future<void> showApprovalDialogByUid(String uid) async {
    final AppUser? user = _pendingUsersById[uid];
    if (user == null) {
      Get.snackbar('Approval request', 'This approval request is no longer pending.');
      return;
    }
    await showApprovalDialog(user);
  }

  Future<void> showApprovalDialog(AppUser user) async {
    if (_isDialogOpen) {
      _queuedApprovalUid = user.uid;
      return;
    }
    if (Get.context == null) {
      _queuedApprovalUid = user.uid;
      return;
    }

    _isDialogOpen = true;
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('User Approval Request'),
        content: Text(
          '${user.name.isEmpty ? user.email : user.name}\n${user.email}\n\nChoose a role to approve this user, or decline access.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Get.back<void>();
              await _declineUser(user);
            },
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () async {
              Get.back<void>();
              await _approvePendingUser(user, AppConstants.employeeRole);
            },
            child: const Text('Employee'),
          ),
          TextButton(
            onPressed: () async {
              Get.back<void>();
              await _approvePendingUser(user, AppConstants.technicianRole);
            },
            child: const Text('Technician'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back<void>();
              await _approvePendingUser(user, AppConstants.ownerRole);
            },
            child: const Text('Owner'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    _isDialogOpen = false;
    _openQueuedDialogIfPossible();
  }

  void _startOwnerPendingUserListener() {
    _pendingUsersSubscription?.cancel();
    _hasPrimedPendingUsers = false;

    _pendingUsersSubscription = _remote.watchPendingUsers().listen(
      (List<Map<String, dynamic>> remoteUsers) async {
        final List<AppUser> users = remoteUsers.map(AppUser.fromMap).toList();
        pendingCount.value = users.length;
        _pendingUsersById
          ..clear()
          ..addEntries(users.map((AppUser user) => MapEntry<String, AppUser>(user.uid, user)));

        final Set<String> currentIds = users.map((AppUser user) => user.uid).toSet();
        if (!_hasPrimedPendingUsers) {
          _knownPendingIds
            ..clear()
            ..addAll(currentIds);
          _hasPrimedPendingUsers = true;
          return;
        }

        final Iterable<AppUser> newlyPendingUsers =
            users.where((AppUser user) => !_knownPendingIds.contains(user.uid));
        _knownPendingIds
          ..clear()
          ..addAll(currentIds);

        for (final AppUser user in newlyPendingUsers) {
          if (_isAppInForeground) {
            await showApprovalDialog(user);
          } else {
            await _showLocalNotification(user);
          }
        }
      },
    );
  }

  void _stopOwnerPendingUserListener() {
    _pendingUsersSubscription?.cancel();
    _pendingUsersSubscription = null;
    _pendingUsersById.clear();
    _knownPendingIds.clear();
    _queuedApprovalUid = null;
    _hasPrimedPendingUsers = false;
    pendingCount.value = 0;
  }

  Future<void> _approvePendingUser(AppUser user, String role) async {
    final AppUser? approver = _currentUser;
    if (approver == null) {
      return;
    }

    try {
      await _approveUser.call(
        targetUser: user,
        role: role,
        approverId: approver.uid,
      );
      await _reloadUserManagementIfOpen();
      Get.snackbar('User approved', '${user.email} is now a $role.');
    } catch (error) {
      Get.snackbar('Approval failed', error.toString());
    }
  }

  Future<void> _declineUser(AppUser user) async {
    final AppUser? approver = _currentUser;
    if (approver == null) {
      return;
    }

    try {
      await _updateUser.call(
        user.copyWith(
          status: AppConstants.blockedStatus,
          updatedAt: DateTime.now(),
        ),
        actorId: approver.uid,
      );
      await _reloadUserManagementIfOpen();
      Get.snackbar('User declined', '${user.email} has been blocked.');
    } catch (error) {
      Get.snackbar('Decline failed', error.toString());
    }
  }

  Future<void> _showLocalNotification(AppUser user) {
    return _notificationsPlugin.show(
      user.uid.hashCode,
      'New user approval request',
      '${user.name.isEmpty ? user.email : user.name} is waiting for approval.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.approvalNotificationChannelId,
          AppConstants.approvalNotificationChannelName,
          icon: _notificationIcon,
          channelDescription: AppConstants.approvalNotificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: user.uid,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    final String? uid = response.payload;
    if (uid == null || uid.isEmpty) {
      return;
    }
    _queuedApprovalUid = uid;
    _openQueuedDialogIfPossible();
  }

  void _openQueuedDialogIfPossible() {
    if (!_isAppInForeground || _queuedApprovalUid == null) {
      return;
    }

    final String uid = _queuedApprovalUid!;
    _queuedApprovalUid = null;
    showApprovalDialogByUid(uid);
  }

  Future<void> _reloadUserManagementIfOpen() async {
    if (!Get.isRegistered<UsersController>()) {
      return;
    }
    await Get.find<UsersController>().load();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingUsersSubscription?.cancel();
    super.onClose();
  }
}
