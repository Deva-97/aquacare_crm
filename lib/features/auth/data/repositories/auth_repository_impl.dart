import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/remote/firebase/firebase_auth_remote_data_source.dart';
import '../../../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authRemote,
    this._firestoreRemote,
  );

  final FirebaseAuthRemoteDataSource _authRemote;
  final FirestoreRemoteDataSource _firestoreRemote;

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? firebaseUser = _authRemote.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return refreshCurrentUser();
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    final User? firebaseUser = _authRemote.currentUser;
    if (firebaseUser == null) {
      return Stream<AppUser?>.value(null);
    }

    return _firestoreRemote.watchUser(firebaseUser.uid).asyncMap((Map<String, dynamic>? remoteUser) async {
      if (remoteUser == null) {
        return null;
      }
      return AppUser.fromMap(remoteUser);
    });
  }

  @override
  Future<AppUser?> refreshCurrentUser() async {
    final User? firebaseUser = _authRemote.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final Map<String, dynamic>? remoteUser = await _firestoreRemote.getUser(firebaseUser.uid);
    if (remoteUser == null) {
      final bool isInitialOwner = await _firestoreRemote.claimInitialOwner(firebaseUser.uid);
      final DateTime now = DateTime.now();
      final AppUser created = AppUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        role: isInitialOwner ? AppConstants.ownerRole : AppConstants.pendingRole,
        status: isInitialOwner ? AppConstants.approvedStatus : AppConstants.pendingStatus,
        createdAt: now,
        updatedAt: now,
        approvedBy: isInitialOwner ? firebaseUser.uid : null,
      );
      await _firestoreRemote.setUser(created.uid, created.toMap());
      return created;
    }

    return AppUser.fromMap(remoteUser);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final UserCredential credential = await _authRemote.signInWithGoogle();
    final User? firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'No Firebase user was returned.',
      );
    }
    final AppUser? user = await refreshCurrentUser();
    if (user == null) {
      throw FirebaseAuthException(
        code: 'session-init-failed',
        message: 'Unable to initialize session.',
      );
    }
    return user;
  }

  @override
  Future<void> signOut() => _authRemote.signOut();
}
