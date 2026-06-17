import 'package:get/get.dart';

import '../../../../core/sync/app_data_refresh_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

class DashboardController extends GetxController {
  DashboardController(
    this._summaryUseCase,
    this._authController,
  );

  final GetDashboardSummaryUseCase _summaryUseCase;
  final AuthController _authController;

  final Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  final RxBool isLoading = false.obs;
  Worker? _refreshWorker;
  Worker? _userWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AppDataRefreshService>()) {
      _refreshWorker = ever<int>(
        Get.find<AppDataRefreshService>().dashboardRevision,
        (_) {
          loadSummary();
        },
      );
    }
    // If the user isn't available yet when onInit runs (race between
    // AuthController initialization and route creation), retry as soon
    // as currentUser becomes non-null.
    _userWorker = ever<AppUser?>(_authController.currentUser, (user) {
      if (user != null && summary.value == null && !isLoading.value) {
        loadSummary();
      }
    });
    loadSummary();
  }

  Future<void> loadSummary() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    isLoading.value = true;
    try {
      summary.value = await _summaryUseCase.call(user);
    } catch (error) {
      Get.snackbar('Dashboard load failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _refreshWorker?.dispose();
    _userWorker?.dispose();
    super.onClose();
  }
}
