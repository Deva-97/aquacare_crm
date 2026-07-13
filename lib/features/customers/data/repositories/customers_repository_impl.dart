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
    final Customer deleted = customer.copyWith(isDeleted: true, updatedAt: DateTime.now());
    await _remote.upsertDocument(AppConstants.customersCollection, deleted.id, deleted.toMap());
    _notifyCustomersChanged();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final Map<String, dynamic>? data = await _remote.fetchDocument(AppConstants.customersCollection, id);
    if (data == null) return null;
    final Customer customer = Customer.fromMap(data);
    return customer.isDeleted ? null : customer;
  }

  @override
  Future<List<Customer>> getCustomers(AppUser currentUser, {String query = ''}) async {
    final List<Customer> customers = await _fetchVisibleCustomers();
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;
    return customers.where((Customer c) {
      return c.customerName.toLowerCase().contains(q) ||
          c.mobileNumber.contains(q) ||
          c.city.toLowerCase().contains(q) ||
          c.pincode.contains(q);
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
  Future<bool> hasDuplicate({required String mobileNumber, String? excludingId}) async {
    final String mobile = mobileNumber.trim();
    if (mobile.isEmpty) return false;
    final List<Map<String, dynamic>> results = await _remote.fetchWhereEquals(
      path: AppConstants.customersCollection,
      field: 'mobileNumber',
      value: mobile,
    );
    return results.any((item) => item['isDeleted'] != true && item['id'] != excludingId);
  }

  @override
  Future<void> saveCustomer(Customer customer, AppUser actor, {bool isUpdate = false}) async {
    final bool duplicate = await hasDuplicate(
      mobileNumber: customer.mobileNumber,
      excludingId: isUpdate ? customer.id : null,
    );
    if (duplicate) {
      throw AppException('This mobile number is already registered to another customer.');
    }
    final Customer prepared = customer.copyWith(updatedAt: DateTime.now());
    await _remote.upsertDocument(AppConstants.customersCollection, prepared.id, prepared.toMap());
    _notifyCustomersChanged();
  }

  @override
  Future<List<String>> getCities() => _remote.fetchCities();

  @override
  Future<void> saveCity(String cityName) => _remote.saveCity(cityName);

  @override
  Future<void> deleteCity(String cityName) => _remote.deleteCity(cityName);

  void _notifyCustomersChanged() {
    if (Get.isRegistered<AppDataRefreshService>()) {
      Get.find<AppDataRefreshService>().notifyCustomersChanged();
    }
  }

  Future<List<Customer>> _fetchVisibleCustomers() async {
    final List<Map<String, dynamic>> data =
        await _remote.fetchCollection(AppConstants.customersCollection);
    final List<Customer> customers =
        data.map(Customer.fromMap).where((Customer c) => !c.isDeleted).toList();
    customers.sort((Customer a, Customer b) => b.updatedAt.compareTo(a.updatedAt));
    return customers;
  }
}
