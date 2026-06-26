import '../../../users/domain/entities/app_user.dart';
import '../entities/customer.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getCustomers(AppUser currentUser, {String query = ''});
  Future<Customer?> getCustomerById(String id);
  Future<void> saveCustomer(Customer customer, AppUser actor, {bool isUpdate = false});
  Future<void> deleteCustomer(Customer customer, AppUser actor);
  Future<bool> hasDuplicate({required String mobileNumber, String? excludingId});
  Future<List<Customer>> findByName(String name, {String? excludingId});
  Future<List<String>> getCities();
  Future<void> saveCity(String cityName);
  Future<void> deleteCity(String cityName);
}
