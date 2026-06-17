import 'package:get/get.dart';

import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/installation.dart';
import '../../domain/usecases/installations_usecases.dart';

class InstallationsController extends GetxController {
  InstallationsController(
    this._getInstallations,
    this._authController,
  );

  final GetInstallationsUseCase _getInstallations;
  final AuthController _authController;

  final RxList<Installation> installations = <Installation>[].obs;
  final RxBool isLoading = false.obs;
  String? _activeCustomerId;
  Worker? _refreshWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AppDataRefreshService>()) {
      _refreshWorker = ever<int>(
        Get.find<AppDataRefreshService>().installationsRevision,
        (_) {
          reload();
        },
      );
    }
  }

  Future<void> load({String? customerId}) async {
    _activeCustomerId = customerId;
    await _load(customerId: customerId);
  }

  Future<void> reload() {
    return _load(customerId: _activeCustomerId);
  }

  Future<void> _load({required String? customerId}) async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    isLoading.value = true;
    try {
      installations.assignAll(
        await _getInstallations.call(
          user,
          customerId: customerId,
        ),
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
