import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../contacts/domain/entities/contact_export_result.dart';
import '../../../contacts/domain/usecases/export_customer_to_contacts_usecase.dart';
import '../../domain/entities/customer.dart';

class CustomerDetailsController extends GetxController {
  CustomerDetailsController(
    this._exportCustomerToContacts,
    this._authController,
  );

  final ExportCustomerToContactsUseCase _exportCustomerToContacts;
  final AuthController _authController;

  final RxBool isExportingContact = false.obs;

  Future<void> exportToContacts(Customer customer) async {
    final user = _authController.currentUser.value;
    if (user == null) {
      Get.snackbar('Export failed', 'Please sign in again.');
      return;
    }

    isExportingContact.value = true;
    try {
      final ContactExportResult result = await _exportCustomerToContacts.call(
        customer: customer,
        currentUser: user,
      );
      _showResult(result);
    } catch (error) {
      Get.snackbar('Export failed', _readableError(error));
    } finally {
      isExportingContact.value = false;
    }
  }

  void _showResult(ContactExportResult result) {
    switch (result.status) {
      case ContactExportStatus.exported:
        Get.snackbar('Contact exported', result.message);
      case ContactExportStatus.skippedDuplicate:
        Get.snackbar('Already in contacts', result.message);
      case ContactExportStatus.skippedInvalidMobile:
        Get.snackbar('Export skipped', result.message);
      case ContactExportStatus.permissionDenied:
        Get.snackbar('Permission denied', result.message);
      case ContactExportStatus.permissionPermanentlyDenied:
        Get.snackbar(
          'Permission required',
          result.message,
          mainButton: TextButton(
            onPressed: _exportCustomerToContacts.openPermissionSettings,
            child: const Text('Open Settings'),
          ),
        );
      case ContactExportStatus.permissionRestricted:
        Get.snackbar('Permission restricted', result.message);
      case ContactExportStatus.failed:
        Get.snackbar('Export failed', result.message);
    }
  }

  String _readableError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
}
