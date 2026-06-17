import 'dart:convert';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../../dashboard/domain/entities/audit_log.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/services_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<AuditLog>> getAuditLogs() async {
    final List<Map<String, dynamic>> logs = await _remote.fetchAuditLogs();
    return logs.map(AuditLog.fromMap).toList();
  }

  @override
  Future<ServiceRequest?> getServiceById(String id) async {
    final Map<String, dynamic>? data = await _remote.fetchDocument(
      AppConstants.serviceRequestsCollection,
      id,
    );
    if (data == null) {
      return null;
    }
    final ServiceRequest service = ServiceRequest.fromMap(data);
    return service.isDeleted ? null : service;
  }

  @override
  Future<List<ServiceRequest>> getServices(AppUser currentUser) async {
    late final List<Map<String, dynamic>> data;
    if (currentUser.isOwner) {
      data = await _remote.fetchCollection(AppConstants.serviceRequestsCollection);
    } else if (currentUser.isTechnician) {
      data = await _remote.fetchWhereEquals(
        path: AppConstants.serviceRequestsCollection,
        field: 'assignedTechnicianId',
        value: currentUser.uid,
      );
    } else {
      data = <Map<String, dynamic>>[];
    }
    final List<ServiceRequest> services = data
        .map(ServiceRequest.fromMap)
        .where((ServiceRequest s) => !s.isDeleted)
        .toList();
    services.sort(
      (ServiceRequest a, ServiceRequest b) => b.scheduledDate.compareTo(a.scheduledDate),
    );
    return services;
  }

  @override
  Future<void> saveService(ServiceRequest service, AppUser actor, {bool isUpdate = false}) async {
    if (!actor.isOwner) {
      throw AppException('Only owners can create or edit service requests.');
    }
    final ServiceRequest prepared = service.copyWith(updatedAt: DateTime.now());
    await _remote.upsertDocument(
      AppConstants.serviceRequestsCollection,
      prepared.id,
      prepared.toMap(),
    );
    await _createAuditLog(
      action: isUpdate ? 'service_updated' : 'service_created',
      actorId: actor.uid,
      entityId: prepared.id,
      payload: prepared.toMap(),
    );
    _notifyServicesChanged();
  }

  @override
  Future<void> updateTechnicianService(ServiceRequest service, AppUser actor) async {
    if (!actor.isTechnician || service.assignedTechnicianId != actor.uid) {
      throw AppException('You can update only service jobs assigned to you.');
    }
    final ServiceRequest prepared = service.copyWith(updatedAt: DateTime.now());
    await _remote.upsertDocument(
      AppConstants.serviceRequestsCollection,
      prepared.id,
      prepared.toMap(),
    );
    _notifyServicesChanged();
  }

  void _notifyServicesChanged() {
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyServicesChanged();
    }
  }

  Future<void> _createAuditLog({
    required String action,
    required String actorId,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final AuditLog log = AuditLog(
      id: _uuid.v4(),
      action: action,
      entityType: AppConstants.serviceRequestsCollection,
      entityId: entityId,
      performedBy: actorId,
      oldValue: '',
      newValue: jsonEncode(payload),
      createdAt: DateTime.now(),
    );
    await _remote.upsertDocument(
      AppConstants.auditLogsCollection,
      log.id,
      log.toMap(),
    );
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyAuditLogsChanged();
    }
  }
}
