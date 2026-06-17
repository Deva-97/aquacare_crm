import '../entities/audit_log.dart';
import '../../../services/domain/repositories/services_repository.dart';

class GetAuditLogsUseCase {
  GetAuditLogsUseCase(this._repository);

  final ServicesRepository _repository;

  Future<List<AuditLog>> call() => _repository.getAuditLogs();
}
