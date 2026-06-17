import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;

  @override
  Future<void> deleteCustomer(Customer customer, AppUser actor) async {
    if (!actor.isOwner) {
      throw AppException('Only owners can delete customers.');
    }
    final Customer deleted = customer.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    await _remote.upsertDocument(
      AppConstants.customersCollection,
      deleted.id,
      deleted.toMap(),
    );
    _notifyCustomersChanged();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final Map<String, dynamic>? data = await _remote.fetchDocument(
      AppConstants.customersCollection,
      id,
    );
    if (data == null) {
      return null;
    }
    final Customer customer = Customer.fromMap(data);
    return customer.isDeleted ? null : customer;
  }

  @override
  Future<List<Customer>> getCustomers(AppUser currentUser, {String query = ''}) async {
    final List<Customer> customers = await _fetchVisibleCustomers(currentUser);
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return customers;
    }

    final Set<String> matchingSerialCustomerIds = await _customerIdsMatchingSerial(normalizedQuery);
    return customers.where((Customer customer) {
      return customer.customerName.toLowerCase().contains(normalizedQuery) ||
          customer.mobileNumber.contains(normalizedQuery) ||
          customer.whatsappNumber.contains(normalizedQuery) ||
          customer.area.toLowerCase().contains(normalizedQuery) ||
          matchingSerialCustomerIds.contains(customer.id);
    }).toList();
  }

  @override
  Future<List<Customer>> findByName(String name, {String? excludingId}) async {
    final List<Map<String, dynamic>> all =
        await _remote.fetchCollection(AppConstants.customersCollection);
    final String normalized = name.trim().toLowerCase();
    return all
        .map(Customer.fromMap)
        .where((Customer c) =>
            !c.isDeleted &&
            c.id != excludingId &&
            c.customerName.trim().toLowerCase() == normalized)
        .toList();
  }

  @override
  Future<bool> hasDuplicate({
    required String mobileNumber,
    required String whatsappNumber,
    String? excludingId,
  }) async {
    final List<Map<String, dynamic>> all =
        await _remote.fetchCollection(AppConstants.customersCollection);
    final String mobile = mobileNumber.trim();
    final String whatsapp = whatsappNumber.trim();
    return all.map(Customer.fromMap).where((Customer c) {
      return !c.isDeleted && c.id != excludingId;
    }).any((Customer c) {
      return c.mobileNumber == mobile ||
          c.whatsappNumber == whatsapp ||
          c.mobileNumber == whatsapp ||
          c.whatsappNumber == mobile;
    });
  }

  @override
  Future<void> saveCustomer(Customer customer, AppUser actor, {bool isUpdate = false}) async {
    final bool duplicate = await hasDuplicate(
      mobileNumber: customer.mobileNumber,
      whatsappNumber: customer.whatsappNumber,
      excludingId: isUpdate ? customer.id : null,
    );
    if (duplicate) {
      throw AppException('Another active customer already uses that mobile or WhatsApp number.');
    }

    if (!actor.isOwner && isUpdate && customer.createdBy != actor.uid && customer.assignedEmployeeId != actor.uid) {
      throw AppException('You do not have permission to edit this customer.');
    }

    final Customer prepared = customer.copyWith(updatedAt: DateTime.now());
    await _remote.upsertDocument(
      AppConstants.customersCollection,
      prepared.id,
      prepared.toMap(),
    );
    _notifyCustomersChanged();
  }

  void _notifyCustomersChanged() {
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyCustomersChanged();
    }
  }

  Future<List<Customer>> _fetchVisibleCustomers(AppUser currentUser) async {
    List<Map<String, dynamic>> data;
    if (currentUser.isOwner) {
      data = await _remote.fetchCollection(AppConstants.customersCollection);
    } else {
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
      final Map<String, Map<String, dynamic>> merged = <String, Map<String, dynamic>>{};
      for (final Map<String, dynamic> item in <Map<String, dynamic>>[...created, ...assigned]) {
        merged[item['id'] as String] = item;
      }
      data = merged.values.toList();
    }
    final List<Customer> customers = data
        .map(Customer.fromMap)
        .where((Customer c) => !c.isDeleted)
        .toList();
    customers.sort((Customer a, Customer b) => b.updatedAt.compareTo(a.updatedAt));
    return customers;
  }

  Future<Set<String>> _customerIdsMatchingSerial(String normalizedQuery) async {
    final List<Map<String, dynamic>> installations =
        await _remote.fetchCollection(AppConstants.installationsCollection);
    return installations
        .map((Map<String, dynamic> item) {
          final bool isDeleted = item['isDeleted'] == true || item['isDeleted'] == 1;
          final String serialNumber =
              (item['serialNumber'] as String? ?? '').toLowerCase();
          if (isDeleted || !serialNumber.contains(normalizedQuery)) {
            return null;
          }
          return item['customerId'] as String?;
        })
        .whereType<String>()
        .toSet();
  }
}
