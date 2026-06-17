import 'package:get/get.dart';

import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/usecases/services_usecases.dart';

class ServicesController extends GetxController {
  ServicesController(
    this._getServices,
    this._authController,
  );

  final GetServicesUseCase _getServices;
  final AuthController _authController;

  final RxList<ServiceRequest> services = <ServiceRequest>[].obs;
  final RxBool isLoading = false.obs;
  Worker? _refreshWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AppDataRefreshService>()) {
      _refreshWorker = ever<int>(
        Get.find<AppDataRefreshService>().servicesRevision,
        (_) {
          loadServices();
        },
      );
    }
    loadServices();
  }

  Future<void> loadServices() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    isLoading.value = true;
    try {
      services.assignAll(
        await _getServices.call(user),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _refreshWorker?.dispose();
    super.onClose();
  }
}
