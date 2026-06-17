import '../../../users/domain/entities/app_user.dart';
import '../entities/installation.dart';
import '../repositories/installations_repository.dart';

class GetInstallationsUseCase {
  GetInstallationsUseCase(this._repository);
  final InstallationsRepository _repository;

  Future<List<Installation>> call(
    AppUser currentUser, {
    String? customerId,
  }) {
    return _repository.getInstallations(currentUser, customerId: customerId);
  }
}

class GetInstallationByIdUseCase {
  GetInstallationByIdUseCase(this._repository);
  final InstallationsRepository _repository;
  Future<Installation?> call(String id) => _repository.getInstallationById(id);
}

class SaveInstallationUseCase {
  SaveInstallationUseCase(this._repository);
  final InstallationsRepository _repository;

  Future<void> call(Installation installation, AppUser actor, {bool isUpdate = false}) {
    return _repository.saveInstallation(installation, actor, isUpdate: isUpdate);
  }
}
