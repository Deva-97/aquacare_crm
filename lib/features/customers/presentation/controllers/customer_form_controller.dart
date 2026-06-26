import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customers_usecases.dart';

class CustomerFormController extends GetxController {
  CustomerFormController(
    this._saveCustomer,
    this._checkDuplicate,
    this._findSameName,
    this._getCities,
    this._authController,
  );

  final SaveCustomerUseCase _saveCustomer;
  final CheckDuplicateMobileUseCase _checkDuplicate;
  final FindSameNameCustomersUseCase _findSameName;
  final GetCitiesUseCase _getCities;
  final AuthController _authController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityTextController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  final RxList<String> availableCities = <String>[].obs;
  final Rxn<String> selectedCity = Rxn<String>();

  // '', 'checking', 'available', 'taken'
  final RxString mobileStatus = ''.obs;

  final RxBool isLoading = false.obs;

  Customer? existingCustomer;
  Timer? _mobileDebounce;

  bool get isAdmin => _authController.currentUser.value?.isAdmin == true;

  @override
  void onInit() {
    super.onInit();
    existingCustomer = Get.arguments as Customer?;
    _seedExistingValues();
    _loadCities();
  }

  void _seedExistingValues() {
    final Customer? customer = existingCustomer;
    if (customer == null) return;
    nameController.text = customer.customerName;
    mobileController.text = customer.mobileNumber;
    addressController.text = customer.address;
    cityTextController.text = customer.city;
    selectedCity.value = customer.city.isNotEmpty ? customer.city : null;
    pincodeController.text = customer.pincode;
    mobileStatus.value = 'available';
  }

  Future<void> _loadCities() async {
    availableCities.assignAll(await _getCities.call());
  }

  void onMobileChanged(String value) {
    final String trimmed = value.trim();
    mobileStatus.value = '';
    _mobileDebounce?.cancel();
    if (trimmed.length < 10) return;
    mobileStatus.value = 'checking';
    _mobileDebounce = Timer(const Duration(milliseconds: 600), () async {
      final bool taken = await _checkDuplicate.call(
        mobileNumber: trimmed,
        excludingId: existingCustomer?.id,
      );
      mobileStatus.value = taken ? 'taken' : 'available';
    });
  }

  String get effectiveCity => selectedCity.value ?? '';

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final String city = effectiveCity;
    if (city.isEmpty) {
      Get.snackbar('City required', 'Please select or enter a city.');
      return;
    }

    if (mobileStatus.value == 'taken') {
      Get.snackbar('Duplicate mobile', 'This mobile number is already registered.');
      return;
    }

    final actor = _authController.currentUser.value;
    if (actor == null) return;

    isLoading.value = true;
    try {
      final bool duplicate = await _checkDuplicate.call(
        mobileNumber: mobileController.text.trim(),
        excludingId: existingCustomer?.id,
      );
      if (duplicate) {
        Get.snackbar('Duplicate mobile', 'This mobile number is already registered to another customer.');
        return;
      }

      final List<Customer> sameNameMatches = await _findSameName.call(
        nameController.text.trim(),
        excludingId: existingCustomer?.id,
      );
      if (sameNameMatches.isNotEmpty) {
        isLoading.value = false;
        final Customer match = sameNameMatches.first;
        final bool? proceed = await Get.dialog<bool>(AlertDialog(
          title: const Text('Possible Duplicate'),
          content: Text(
            'A customer named "${match.customerName}" already exists '
            'with mobile ${match.mobileNumber}.\n\nAre you sure this is a different person?',
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('Continue')),
          ],
        ));
        if (proceed != true) return;
        isLoading.value = true;
      }

      final DateTime now = DateTime.now();
      final Customer customer = Customer(
        id: existingCustomer?.id ?? const Uuid().v4(),
        customerName: nameController.text.trim(),
        mobileNumber: mobileController.text.trim(),
        address: addressController.text.trim(),
        city: city,
        pincode: pincodeController.text.trim(),
        createdBy: existingCustomer?.createdBy ?? actor.uid,
        createdAt: existingCustomer?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );

      await _saveCustomer.call(customer, actor, isUpdate: existingCustomer != null);

      Get.back(result: true);
    } catch (error) {
      Get.snackbar('Save failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateRequired(String? value, String fieldName) =>
      Validators.requiredField(value, fieldName);

  String? validateMobile(String? value) => Validators.mobile(value);

  @override
  void onClose() {
    _mobileDebounce?.cancel();
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    cityTextController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
