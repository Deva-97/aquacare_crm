import '../../../users/domain/entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.getCurrentUser();
}

class WatchCurrentUserUseCase {
  WatchCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.watchCurrentUser();
}

class RefreshCurrentUserUseCase {
  RefreshCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.refreshCurrentUser();
}

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithGoogle();
}

class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
