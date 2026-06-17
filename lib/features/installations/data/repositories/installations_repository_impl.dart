import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/entities/installation.dart';
import '../../domain/repositories/installations_repository.dart';

class InstallationsRepositoryImpl implements InstallationsRepository {
  InstallationsRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;

  @override
  Future<Installation?> getInstallationById(String id) async {
    final Map<String, dynamic>? data = await _remote.fetchDocument(
      AppConstants.installationsCollection,
      id,
    );
    if (data == null) {
      return null;
    }
    final Installation installation = Installation.fromMap(data);
    return installation.isDeleted ? null : installation;
  }

  @override
  Future<List<Installation>> getInstallations(AppUser currentUser, {String? customerId}) async {
    List<Map<String, dynamic>> data = <Map<String, dynamic>>[];
    if (customerId != null && customerId.isNotEmpty) {
      data = await _remote.fetchWhereEquals(
        path: AppConstants.installationsCollection,
        field: 'customerId',
        value: customerId,
      );
    } else if (currentUser.isOwner) {
      data = await _remote.fetchCollection(AppConstants.installationsCollection);
    } else {
      final List<String> customerIds = await _fetchVisibleCustomerIds(currentUser);
      if (customerIds.isNotEmpty) {
        data = await _remote.fetchWhereIn(
          path: AppConstants.installationsCollection,
          field: 'customerId',
          values: customerIds,
        );
      }
    }

    final List<Installation> installations = data
        .map(Installation.fromMap)
        .where((Installation i) => !i.isDeleted)
        .toList();
    installations.sort(
      (Installation a, Installation b) => b.installationDate.compareTo(a.installationDate),
    );
    return installations;
  }

  @override
  Future<void> saveInstallation(
    Installation installation,
    AppUser actor, {
    bool isUpdate = false,
  }) async {
    if (!actor.isOwner && !actor.isEmployee) {
      throw AppException('Only owners and employees can save installations.');
    }
    final Installation prepared = installation.copyWith(updatedAt: DateTime.now());
    await _remote.upsertDocument(
      AppConstants.installationsCollection,
      prepared.id,
      prepared.toMap(),
    );
    _notifyInstallationsChanged();
  }

  void _notifyInstallationsChanged() {
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyInstallationsChanged();
    }
  }

  Future<List<String>> _fetchVisibleCustomerIds(AppUser currentUser) async {
    final List<Map<String, dynamic>> created = await _remote.fetchWhereEquals(
      path: AppConstants.customersCollection,
      field: 'createdBy',
      value: currentUser.uid,
    );
    final List<Map<String, dynamic>> assigned = await _remote.fetchWhereEquals(
      path: AppConstants.customersCollection,
      field: 'assignedEmployeeId',
      value: currentUser.uid,
    );
    return <Map<String, dynamic>>[...created, ...assigned]
        .where((Map<String, dynamic> c) {
          return c['isDeleted'] != true && c['isDeleted'] != 1;
        })
        .map((Map<String, dynamic> c) => c['id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }
}
