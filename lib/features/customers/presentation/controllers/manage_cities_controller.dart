import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/usecases/customers_usecases.dart';

class ManageCitiesController extends GetxController {
  ManageCitiesController(this._getCities, this._saveCity, this._deleteCity);

  final GetCitiesUseCase _getCities;
  final SaveCityUseCase _saveCity;
  final DeleteCityUseCase _deleteCity;

  final RxList<String> cities = <String>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController addController = TextEditingController();
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCities();
  }

  List<String> get filteredCities {
    final String q = query.value.trim().toLowerCase();
    if (q.isEmpty) return cities;
    return cities.where((c) => c.toLowerCase().contains(q)).toList();
  }

  bool get hasExactMatch {
    final String q = query.value.trim().toLowerCase();
    if (q.isEmpty) return true;
    return cities.any((c) => c.toLowerCase() == q);
  }

  void onSearchChanged(String value) => query.value = value;

  Future<void> loadCities() async {
    isLoading.value = true;
    try {
      cities.assignAll(await _getCities.call());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCity() async {
    final String name = addController.text.trim();
    if (name.isEmpty) return;
    if (cities.any((c) => c.toLowerCase() == name.toLowerCase())) {
      Get.snackbar('Already exists', '"$name" is already in the list.');
      return;
    }
    isLoading.value = true;
    try {
      await _saveCity.call(name);
      addController.clear();
      query.value = '';
      await loadCities();
      Get.snackbar('City added', '"$name" was added successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCity(String city) async {
    isLoading.value = true;
    try {
      await _deleteCity.call(city);
      cities.remove(city);
      Get.snackbar('Removed', '"$city" was removed.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    addController.dispose();
    super.onClose();
  }
}
