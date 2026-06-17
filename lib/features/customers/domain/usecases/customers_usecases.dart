import '../../../users/domain/entities/app_user.dart';
import '../entities/customer.dart';
import '../repositories/customers_repository.dart';

class GetCustomersUseCase {
  GetCustomersUseCase(this._repository);
  final CustomersRepository _repository;

  Future<List<Customer>> call(
    AppUser currentUser, {
    String query = '',
  }) {
    return _repository.getCustomers(currentUser, query: query);
  }
}

class GetCustomerByIdUseCase {
  GetCustomerByIdUseCase(this._repository);
  final CustomersRepository _repository;

  Future<Customer?> call(String id) => _repository.getCustomerById(id);
}

class SaveCustomerUseCase {
  SaveCustomerUseCase(this._repository);
  final CustomersRepository _repository;

  Future<void> call(Customer customer, AppUser actor, {bool isUpdate = false}) {
    return _repository.saveCustomer(customer, actor, isUpdate: isUpdate);
  }
}

class DeleteCustomerUseCase {
  DeleteCustomerUseCase(this._repository);
  final CustomersRepository _repository;

  Future<void> call(Customer customer, AppUser actor) {
    return _repository.deleteCustomer(customer, actor);
  }
}

class CheckDuplicateCustomerUseCase {
  CheckDuplicateCustomerUseCase(this._repository);
  final CustomersRepository _repository;

  Future<bool> call({
    required String mobileNumber,
    required String whatsappNumber,
    String? excludingId,
  }) {
    return _repository.hasDuplicate(
      mobileNumber: mobileNumber,
      whatsappNumber: whatsappNumber,
      excludingId: excludingId,
    );
  }
}

class FindSameNameCustomersUseCase {
  FindSameNameCustomersUseCase(this._repository);
  final CustomersRepository _repository;

  Future<List<Customer>> call(String name, {String? excludingId}) {
    return _repository.findByName(name, excludingId: excludingId);
  }
}
