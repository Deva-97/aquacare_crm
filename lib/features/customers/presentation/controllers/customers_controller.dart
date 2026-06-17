import 'package:get/get.dart';

import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customers_usecases.dart';

class CustomersController extends GetxController {
  CustomersController(
    this._getCustomers,
    this._deleteCustomer,
    this._authController,
  );

  final GetCustomersUseCase _getCustomers;
  final DeleteCustomerUseCase _deleteCustomer;
  final AuthController _authController;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  Worker? _refreshWorker;

  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AppDataRefreshService>()) {
      _refreshWorker = ever<int>(
        Get.find<AppDataRefreshService>().customersRevision,
        (_) => loadCustomers(),
      );
    }
    // Reload when auth finishes initializing (currentUser may be null on first call)
    _authWorker = ever<AppUser?>(_authController.currentUser, (AppUser? user) {
      if (user != null) loadCustomers();
    });
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    isLoading.value = true;
    try {
      customers.assignAll(
        await _getCustomers.call(
          user,
          query: searchQuery.value,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(Customer customer) async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    await _deleteCustomer.call(customer, user);
    await loadCustomers();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
    loadCustomers();
  }

  @override
  void onClose() {
    _refreshWorker?.dispose();
    _authWorker?.dispose();
    super.onClose();
  }
}
