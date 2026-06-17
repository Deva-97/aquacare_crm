import '../../../dashboard/domain/entities/audit_log.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/service_request.dart';

abstract class ServicesRepository {
  Future<List<ServiceRequest>> getServices(AppUser currentUser);
  Future<ServiceRequest?> getServiceById(String id);
  Future<void> saveService(ServiceRequest service, AppUser actor, {bool isUpdate = false});
  Future<void> updateTechnicianService(ServiceRequest service, AppUser actor);
  Future<List<AuditLog>> getAuditLogs();
}
