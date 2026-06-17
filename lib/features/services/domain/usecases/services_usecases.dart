import '../../../dashboard/domain/entities/audit_log.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/service_request.dart';
import '../repositories/services_repository.dart';

class GetServicesUseCase {
  GetServicesUseCase(this._repository);
  final ServicesRepository _repository;

  Future<List<ServiceRequest>> call(
    AppUser currentUser,
  ) {
    return _repository.getServices(currentUser);
  }
}

class GetServiceByIdUseCase {
  GetServiceByIdUseCase(this._repository);
  final ServicesRepository _repository;
  Future<ServiceRequest?> call(String id) => _repository.getServiceById(id);
}

class SaveServiceUseCase {
  SaveServiceUseCase(this._repository);
  final ServicesRepository _repository;

  Future<void> call(ServiceRequest service, AppUser actor, {bool isUpdate = false}) {
    return _repository.saveService(service, actor, isUpdate: isUpdate);
  }
}

class UpdateTechnicianServiceUseCase {
  UpdateTechnicianServiceUseCase(this._repository);
  final ServicesRepository _repository;

  Future<void> call(ServiceRequest service, AppUser actor) {
    return _repository.updateTechnicianService(service, actor);
  }
}

class GetAuditLogsForOwnerUseCase {
  GetAuditLogsForOwnerUseCase(this._repository);
  final ServicesRepository _repository;
  Future<List<AuditLog>> call() => _repository.getAuditLogs();
}
