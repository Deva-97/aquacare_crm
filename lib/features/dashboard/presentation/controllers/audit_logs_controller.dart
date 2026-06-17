import 'package:get/get.dart';

import '../../../../core/sync/app_data_refresh_service.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/usecases/get_audit_logs_usecase.dart';

class AuditLogsController extends GetxController {
  AuditLogsController(this._useCase);

  final GetAuditLogsUseCase _useCase;
  final RxList<AuditLog> logs = <AuditLog>[].obs;
  final RxBool isLoading = false.obs;
  Worker? _refreshWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AppDataRefreshService>()) {
      _refreshWorker = ever<int>(
        Get.find<AppDataRefreshService>().auditLogsRevision,
        (_) {
          load();
        },
      );
    }
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      logs.assignAll(await _useCase.call());
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
