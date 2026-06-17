import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../../users/domain/entities/app_user.dart';
import '../controllers/service_form_controller.dart';

class ServiceFormPage extends GetView<ServiceFormController> {
  const ServiceFormPage({super.key});

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
      title: controller.technicianMode.value ? 'Update Service Status' : 'Service Request',
      body: Obx(() {
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (!controller.technicianMode.value) ...<Widget>[
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedCustomerId.value.isEmpty ? null : controller.selectedCustomerId.value,
                  items: controller.customers
                      .map((Customer customer) => DropdownMenuItem<String>(
                            value: customer.id,
                            child: Text(customer.customerName),
                          ))
                      .toList(),
                  onChanged: (value) => controller.loadInstallationsForCustomer(value ?? ''),
                  decoration: const InputDecoration(labelText: 'Customer'),
                  validator: (value) => controller.validateRequired(value, 'Customer'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedInstallationId.value.isEmpty ? null : controller.selectedInstallationId.value,
                  items: controller.installations
                      .map((Installation installation) => DropdownMenuItem<String>(
                            value: installation.id,
                            child: Text(installation.serialNumber.isEmpty
                                ? '${installation.filterBrand} ${installation.filterModel}'
                                : installation.serialNumber),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectedInstallationId.value = value ?? '',
                  decoration: const InputDecoration(labelText: 'Installation'),
                  validator: (value) => controller.validateRequired(value, 'Installation'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedServiceType.value,
                  items: AppConstants.serviceTypes
                      .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => controller.selectedServiceType.value = value ?? AppConstants.serviceTypes.first,
                  decoration: const InputDecoration(labelText: 'Service type'),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: controller.complaintController,
                decoration: const InputDecoration(labelText: 'Complaint or notes'),
                maxLines: 3,
                validator: (value) => controller.validateRequired(value, 'Complaint or notes'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedStatus.value,
                items: AppConstants.serviceStatuses
                    .map((status) => DropdownMenuItem<String>(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => controller.selectedStatus.value = value ?? AppConstants.serviceStatuses.first,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 12),
              if (!controller.technicianMode.value)
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedTechnicianId.value.isEmpty ? null : controller.selectedTechnicianId.value,
                  items: controller.technicians
                      .map((AppUser tech) => DropdownMenuItem<String>(
                            value: tech.uid,
                            child: Text(tech.name.isEmpty ? tech.email : tech.name),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectedTechnicianId.value = value ?? '',
                  decoration: const InputDecoration(labelText: 'Assigned technician'),
                  validator: (value) => controller.validateRequired(value, 'Assigned technician'),
                ),
              if (!controller.technicianMode.value) const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scheduled date'),
                subtitle: Text(AppDateUtils.formatDate(controller.scheduledDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(
                  context,
                  controller.scheduledDate.value,
                  (date) => controller.scheduledDate.value = date,
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.completedDate.value != null,
                onChanged: (bool? checked) {
                  if (checked == true) {
                    controller.completedDate.value = DateTime.now();
                  } else {
                    controller.completedDate.value = null;
                  }
                },
                title: const Text('Mark completed date'),
                subtitle: Text(AppDateUtils.formatDate(controller.completedDate.value)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount collected'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.technicianNotesController,
                decoration: const InputDecoration(labelText: 'Technician notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submit,
                child: Text(controller.technicianMode.value ? 'Update Service' : 'Save Service Request'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
