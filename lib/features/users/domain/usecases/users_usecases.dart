import '../entities/app_user.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase {
  GetUsersUseCase(this._repository);
  final UsersRepository _repository;
  Future<List<AppUser>> call() => _repository.getUsers();
}

class GetPendingUsersUseCase {
  GetPendingUsersUseCase(this._repository);
  final UsersRepository _repository;
  Future<List<AppUser>> call() => _repository.getPendingUsers();
}

class GetUserByIdUseCase {
  GetUserByIdUseCase(this._repository);
  final UsersRepository _repository;
  Future<AppUser?> call(String uid) => _repository.getUserById(uid);
}

class ApproveUserUseCase {
  ApproveUserUseCase(this._repository);
  final UsersRepository _repository;

  Future<void> call({
    required AppUser targetUser,
    required String role,
    required String approverId,
  }) {
    return _repository.approveUser(
      targetUser: targetUser,
      role: role,
      approverId: approverId,
    );
  }
}

class UpdateUserUseCase {
  UpdateUserUseCase(this._repository);
  final UsersRepository _repository;

  Future<void> call(AppUser user, {String? actorId}) {
    return _repository.updateUser(user, actorId: actorId);
  }
}
