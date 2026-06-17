import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/usecases/customers_usecases.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../../installations/domain/usecases/installations_usecases.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../../users/domain/usecases/users_usecases.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/usecases/services_usecases.dart';

class ServiceFormController extends GetxController {
  ServiceFormController(
    this._saveService,
    this._updateTechnicianService,
    this._getCustomers,
    this._getInstallations,
    this._getUsers,
    this._authController,
  );

  final SaveServiceUseCase _saveService;
  final UpdateTechnicianServiceUseCase _updateTechnicianService;
  final GetCustomersUseCase _getCustomers;
  final GetInstallationsUseCase _getInstallations;
  final GetUsersUseCase _getUsers;
  final AuthController _authController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController complaintController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController technicianNotesController = TextEditingController();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<Installation> installations = <Installation>[].obs;
  final RxList<AppUser> technicians = <AppUser>[].obs;
  final RxString selectedCustomerId = ''.obs;
  final RxString selectedInstallationId = ''.obs;
  final RxString selectedServiceType = AppConstants.serviceTypes.first.obs;
  final RxString selectedStatus = AppConstants.serviceStatuses.first.obs;
  final RxString selectedTechnicianId = ''.obs;
  final Rx<DateTime> scheduledDate = DateTime.now().obs;
  final Rxn<DateTime> completedDate = Rxn<DateTime>();
  final RxBool isLoading = false.obs;
  final RxBool technicianMode = false.obs;

  ServiceRequest? existingService;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    existingService = args?['service'] as ServiceRequest?;
    technicianMode.value = args?['technicianMode'] == true;
    if (args?['customerId'] is String) {
      selectedCustomerId.value = args!['customerId'] as String;
    }
    _seed();
    loadDependencies();
  }

  void _seed() {
    final service = existingService;
    if (service == null) {
      return;
    }
    selectedCustomerId.value = service.customerId;
    selectedInstallationId.value = service.installationId;
    selectedServiceType.value = service.serviceType;
    selectedStatus.value = service.status;
    selectedTechnicianId.value = service.assignedTechnicianId;
    complaintController.text = service.complaintDescription;
    amountController.text = service.amountCollected.toString();
    technicianNotesController.text = service.technicianNotes;
    scheduledDate.value = service.scheduledDate;
    completedDate.value = service.completedDate;
  }

  Future<void> loadDependencies() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      return;
    }
    customers.assignAll(await _getCustomers.call(user));
    technicians.assignAll(
      (await _getUsers.call()).where((member) => member.isTechnician).toList(),
    );
    await loadInstallationsForCustomer(selectedCustomerId.value);
  }

  Future<void> loadInstallationsForCustomer(String customerId) async {
    selectedCustomerId.value = customerId;
    final user = _authController.currentUser.value;
    if (user == null || customerId.isEmpty) {
      installations.clear();
      return;
    }
    installations.assignAll(await _getInstallations.call(user, customerId: customerId));
    if (installations.isNotEmpty && selectedInstallationId.value.isEmpty) {
      selectedInstallationId.value = installations.first.id;
    }
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
      final ServiceRequest service = ServiceRequest(
        id: existingService?.id ?? const Uuid().v4(),
        customerId: selectedCustomerId.value,
        installationId: selectedInstallationId.value,
        serviceType: selectedServiceType.value,
        complaintDescription: complaintController.text.trim(),
        status: selectedStatus.value,
        assignedTechnicianId: selectedTechnicianId.value,
        scheduledDate: scheduledDate.value,
        completedDate: completedDate.value,
        amountCollected: double.tryParse(amountController.text.trim()) ?? 0,
        technicianNotes: technicianNotesController.text.trim(),
        createdBy: existingService?.createdBy ?? actor.uid,
        createdAt: existingService?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );
      if (technicianMode.value) {
        await _updateTechnicianService.call(service, actor);
      } else {
        await _saveService.call(service, actor, isUpdate: existingService != null);
      }
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
    complaintController.dispose();
    amountController.dispose();
    technicianNotesController.dispose();
    super.onClose();
  }
}
