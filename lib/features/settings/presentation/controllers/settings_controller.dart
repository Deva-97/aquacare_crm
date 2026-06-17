import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../contacts/domain/entities/contact_export_result.dart';
import '../../../contacts/domain/usecases/export_all_customers_to_contacts_usecase.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._exportAllCustomersToContacts,
    this._authController,
  );

  final ExportAllCustomersToContactsUseCase _exportAllCustomersToContacts;
  final AuthController _authController;

  final RxBool isExportingContacts = false.obs;
  final Rxn<ContactBatchExportProgress> exportProgress =
      Rxn<ContactBatchExportProgress>();

  Future<ContactBatchExportResult?> exportAllCustomersToContacts() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      Get.snackbar('Export failed', 'Please sign in again.');
      return null;
    }

    isExportingContacts.value = true;
    exportProgress.value = const ContactBatchExportProgress(
      total: 0,
      processed: 0,
      exported: 0,
      skipped: 0,
      failed: 0,
    );
    try {
      return await _exportAllCustomersToContacts.call(
        currentUser: user,
        onProgress: (ContactBatchExportProgress progress) {
          exportProgress.value = progress;
        },
      );
    } catch (error) {
      Get.snackbar('Export failed', _readableError(error));
      return null;
    } finally {
      isExportingContacts.value = false;
    }
  }

  Future<void> openContactsPermissionSettings() {
    return _exportAllCustomersToContacts.openPermissionSettings();
  }

  String _readableError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
}
