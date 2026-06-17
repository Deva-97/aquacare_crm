import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../contacts/domain/entities/contact_export_result.dart';
import '../../../contacts/domain/usecases/export_customer_to_contacts_usecase.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../../users/domain/usecases/users_usecases.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customers_usecases.dart';

class CustomerFormController extends GetxController {
  CustomerFormController(
    this._saveCustomer,
    this._checkDuplicate,
    this._findSameName,
    this._exportToContacts,
    this._getUsers,
    this._authController,
  );

  final SaveCustomerUseCase _saveCustomer;
  final CheckDuplicateCustomerUseCase _checkDuplicate;
  final FindSameNameCustomersUseCase _findSameName;
  final ExportCustomerToContactsUseCase _exportToContacts;
  final GetUsersUseCase _getUsers;
  final AuthController _authController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController alternateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxString selectedType = 'home'.obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedTechnicianId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<AppUser> teamMembers = <AppUser>[].obs;

  Customer? existingCustomer;

  @override
  void onInit() {
    super.onInit();
    existingCustomer = Get.arguments as Customer?;
    _seedExistingValues();
    loadTeamMembers();
  }

  void _seedExistingValues() {
    final Customer? customer = existingCustomer;
    if (customer == null) {
      return;
    }
    customerNameController.text = customer.customerName;
    mobileController.text = customer.mobileNumber;
    whatsappController.text = customer.whatsappNumber;
    alternateController.text = customer.alternateMobileNumber;
    addressController.text = customer.address;
    areaController.text = customer.area;
    cityController.text = customer.city;
    pincodeController.text = customer.pincode;
    notesController.text = customer.notes;
    selectedType.value = customer.customerType;
    selectedEmployeeId.value = customer.assignedEmployeeId;
    selectedTechnicianId.value = customer.assignedTechnicianId;
  }

  Future<void> loadTeamMembers() async {
    teamMembers.assignAll(await _getUsers.call());
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final AppUser? actor = _authController.currentUser.value;
    if (actor == null) {
      return;
    }
    isLoading.value = true;
    try {
      // 1. Block on mobile/WhatsApp duplicates
      final bool duplicate = await _checkDuplicate.call(
        mobileNumber: mobileController.text.trim(),
        whatsappNumber: whatsappController.text.trim(),
        excludingId: existingCustomer?.id,
      );
      if (duplicate) {
        Get.snackbar('Duplicate customer', 'Mobile or WhatsApp number already exists.');
        return;
      }

      // 2. Warn if same name exists with a different number
      final List<Customer> sameNameMatches = await _findSameName.call(
        customerNameController.text.trim(),
        excludingId: existingCustomer?.id,
      );
      if (sameNameMatches.isNotEmpty) {
        isLoading.value = false;
        final Customer match = sameNameMatches.first;
        final bool? proceed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Possible Duplicate'),
            content: Text(
              'A customer named "${match.customerName}" already exists '
              'with mobile ${match.mobileNumber}.\n\n'
              'Are you sure this is a different person?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          return;
        }
        isLoading.value = true;
      }

      // 3. Build and save customer
      final DateTime now = DateTime.now();
      final Customer customer = Customer(
        id: existingCustomer?.id ?? const Uuid().v4(),
        customerName: customerNameController.text.trim(),
        mobileNumber: mobileController.text.trim(),
        whatsappNumber: whatsappController.text.trim(),
        alternateMobileNumber: alternateController.text.trim(),
        address: addressController.text.trim(),
        area: areaController.text.trim(),
        city: cityController.text.trim(),
        pincode: pincodeController.text.trim(),
        customerType: selectedType.value,
        notes: notesController.text.trim(),
        createdBy: existingCustomer?.createdBy ?? actor.uid,
        assignedEmployeeId: actor.isOwner ? selectedEmployeeId.value : actor.uid,
        assignedTechnicianId: actor.isOwner ? selectedTechnicianId.value : '',
        createdAt: existingCustomer?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );
      await _saveCustomer.call(customer, actor, isUpdate: existingCustomer != null);

      // 4. For new customers, prompt to add to device contacts
      if (existingCustomer == null) {
        isLoading.value = false;
        final bool? addToContacts = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Add to Contacts'),
            content: const Text('Would you like to add this customer to your device contacts?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (addToContacts == true) {
          isLoading.value = true;
          final ContactExportResult result = await _exportToContacts.call(
            customer: customer,
            currentUser: actor,
          );
          isLoading.value = false;
          _showExportResult(result);
        }
      }

      Get.back(result: true);
    } catch (error) {
      Get.snackbar('Save failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _showExportResult(ContactExportResult result) {
    switch (result.status) {
      case ContactExportStatus.exported:
        Get.snackbar('Contact saved', result.message);
      case ContactExportStatus.skippedDuplicate:
        Get.snackbar('Already in contacts', result.message);
      case ContactExportStatus.skippedInvalidMobile:
        Get.snackbar('Export skipped', result.message);
      case ContactExportStatus.permissionDenied:
      case ContactExportStatus.permissionPermanentlyDenied:
        Get.snackbar(
          'Permission required',
          result.message,
          mainButton: TextButton(
            onPressed: _exportToContacts.openPermissionSettings,
            child: const Text('Open Settings'),
          ),
        );
      case ContactExportStatus.permissionRestricted:
        Get.snackbar('Permission restricted', result.message);
      case ContactExportStatus.failed:
        Get.snackbar('Export failed', result.message);
    }
  }

  String? validateRequired(String? value, String fieldName) => Validators.requiredField(value, fieldName);
  String? validateMobile(String? value, {bool required = true}) => Validators.mobile(value, required: required);

  @override
  void onClose() {
    customerNameController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    alternateController.dispose();
    addressController.dispose();
    areaController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
