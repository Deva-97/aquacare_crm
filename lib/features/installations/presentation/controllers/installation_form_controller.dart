import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/usecases/customers_usecases.dart';
import '../../domain/entities/installation.dart';
import '../../domain/usecases/installations_usecases.dart';

class InstallationFormController extends GetxController {
  InstallationFormController(
    this._saveInstallation,
    this._getCustomers,
    this._authController,
  );

  final SaveInstallationUseCase _saveInstallation;
  final GetCustomersUseCase _getCustomers;
  final AuthController _authController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController filterBrandController = TextEditingController();
  final TextEditingController filterModelController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController installedByController = TextEditingController();
  final TextEditingController amountCollectedController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxString selectedCustomerId = ''.obs;
  final RxString selectedFilterType = 'RO'.obs;
  final RxString selectedPaymentStatus = 'paid'.obs;
  final Rx<DateTime> installationDate = DateTime.now().obs;
  final Rx<DateTime> warrantyStartDate = DateTime.now().obs;
  final Rx<DateTime> warrantyEndDate = DateTime.now().add(const Duration(days: 365)).obs;
  final RxBool isLoading = false.obs;

  Installation? existingInstallation;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    existingInstallation = args?['installation'] as Installation?;
    if (args?['customerId'] is String) {
      selectedCustomerId.value = args!['customerId'] as String;
    }
    _seed();
    loadCustomers();
  }

  void _seed() {
    final Installation? installation = existingInstallation;
    if (installation == null) {
      return;
    }
    selectedCustomerId.value = installation.customerId;
    filterBrandController.text = installation.filterBrand;
    filterModelController.text = installation.filterModel;
    serialNumberController.text = installation.serialNumber;
    installedByController.text = installation.installedBy;
    amountCollectedController.text = installation.amountCollected.toString();
    notesController.text = installation.notes;
    selectedFilterType.value = installation.filterType;
    selectedPaymentStatus.value = installation.paymentStatus;
    installationDate.value = installation.installationDate;
    warrantyStartDate.value = installation.warrantyStartDate;
    warrantyEndDate.value = installation.warrantyEndDate;
  }

  Future<void> loadCustomers() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    customers.assignAll(await _getCustomers.call(user));
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final actor = _authController.currentUser.value;
    if (actor == null) {
      return;
    }
    isLoading.value = true;
    try {
      final DateTime now = DateTime.now();
      final Installation installation = Installation(
        id: existingInstallation?.id ?? const Uuid().v4(),
        customerId: selectedCustomerId.value,
        filterBrand: filterBrandController.text.trim(),
        filterModel: filterModelController.text.trim(),
        serialNumber: serialNumberController.text.trim(),
        filterType: selectedFilterType.value,
        installationDate: installationDate.value,
        warrantyStartDate: warrantyStartDate.value,
        warrantyEndDate: warrantyEndDate.value,
        installedBy: installedByController.text.trim(),
        paymentStatus: selectedPaymentStatus.value,
        amountCollected: double.tryParse(amountCollectedController.text.trim()) ?? 0,
        notes: notesController.text.trim(),
        createdBy: existingInstallation?.createdBy ?? actor.uid,
        createdAt: existingInstallation?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );
      await _saveInstallation.call(installation, actor, isUpdate: existingInstallation != null);
      Get.back(result: true);
    } catch (error) {
      Get.snackbar('Save failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateRequired(String? value, String name) => Validators.requiredField(value, name);

  @override
  void onClose() {
    filterBrandController.dispose();
    filterModelController.dispose();
    serialNumberController.dispose();
    installedByController.dispose();
    amountCollectedController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
