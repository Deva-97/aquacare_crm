import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../customers/domain/entities/customer.dart';
import '../controllers/installation_form_controller.dart';

class InstallationFormPage extends GetView<InstallationFormController> {
  const InstallationFormPage({super.key});

  Future<void> _pickDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.existingInstallation == null ? 'Add Installation' : 'Edit Installation',
      body: Obx(() {
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: controller.selectedCustomerId.value.isEmpty ? null : controller.selectedCustomerId.value,
                items: controller.customers
                    .map((Customer customer) => DropdownMenuItem<String>(
                          value: customer.id,
                          child: Text(customer.customerName),
                        ))
                    .toList(),
                onChanged: (value) => controller.selectedCustomerId.value = value ?? '',
                decoration: const InputDecoration(labelText: 'Customer'),
                validator: (value) => controller.validateRequired(value, 'Customer'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.filterBrandController,
                decoration: const InputDecoration(labelText: 'Filter brand'),
                validator: (value) => controller.validateRequired(value, 'Filter brand'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.filterModelController,
                decoration: const InputDecoration(labelText: 'Filter model'),
                validator: (value) => controller.validateRequired(value, 'Filter model'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.serialNumberController,
                decoration: const InputDecoration(labelText: 'Serial number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedFilterType.value,
                items: AppConstants.filterTypes
                    .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => controller.selectedFilterType.value = value ?? AppConstants.filterTypes.first,
                decoration: const InputDecoration(labelText: 'Filter type'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Installation date'),
                subtitle: Text(AppDateUtils.formatDate(controller.installationDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(
                  context,
                  controller.installationDate.value,
                  (date) => controller.installationDate.value = date,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Warranty start date'),
                subtitle: Text(AppDateUtils.formatDate(controller.warrantyStartDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(
                  context,
                  controller.warrantyStartDate.value,
                  (date) => controller.warrantyStartDate.value = date,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Warranty end date'),
                subtitle: Text(AppDateUtils.formatDate(controller.warrantyEndDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(
                  context,
                  controller.warrantyEndDate.value,
                  (date) => controller.warrantyEndDate.value = date,
                ),
              ),
              TextFormField(
                controller: controller.installedByController,
                decoration: const InputDecoration(labelText: 'Installed by'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedPaymentStatus.value,
                items: AppConstants.paymentStatuses
                    .map((status) => DropdownMenuItem<String>(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => controller.selectedPaymentStatus.value = value ?? AppConstants.paymentStatuses.first,
                decoration: const InputDecoration(labelText: 'Payment status'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.amountCollectedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount collected'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submit,
                child: Text(controller.existingInstallation == null ? 'Save Installation' : 'Update Installation'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
