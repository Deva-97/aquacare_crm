import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/domain/entities/app_user.dart';
import '../controllers/customer_form_controller.dart';

class CustomerFormPage extends GetView<CustomerFormController> {
  const CustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: controller.existingCustomer == null ? 'Add Customer' : 'Edit Customer',
      body: Obx(() {
        final bool owner = auth.currentUser.value?.isOwner == true;
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: controller.customerNameController,
                decoration: const InputDecoration(labelText: 'Customer name'),
                validator: (value) => controller.validateRequired(value, 'Customer name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile number'),
                validator: (value) => controller.validateMobile(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp number'),
                validator: (value) => controller.validateMobile(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.alternateController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Alternate mobile number'),
                validator: (value) => controller.validateMobile(value, required: false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => controller.validateRequired(value, 'Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.areaController,
                decoration: const InputDecoration(labelText: 'Area'),
                validator: (value) => controller.validateRequired(value, 'Area'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => controller.validateRequired(value, 'City'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedType.value,
                items: AppConstants.customerTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => controller.selectedType.value = value ?? AppConstants.customerTypes.first,
                decoration: const InputDecoration(labelText: 'Customer type'),
              ),
              if (owner) ...<Widget>[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedEmployeeId.value.isEmpty ? null : controller.selectedEmployeeId.value,
                  items: controller.teamMembers
                      .where((member) => member.isEmployee)
                      .map((AppUser member) => DropdownMenuItem<String>(
                            value: member.uid,
                            child: Text(member.name.isEmpty ? member.email : member.name),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectedEmployeeId.value = value ?? '',
                  decoration: const InputDecoration(labelText: 'Assigned employee'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: controller.selectedTechnicianId.value.isEmpty ? null : controller.selectedTechnicianId.value,
                  items: controller.teamMembers
                      .where((member) => member.isTechnician)
                      .map((AppUser member) => DropdownMenuItem<String>(
                            value: member.uid,
                            child: Text(member.name.isEmpty ? member.email : member.name),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectedTechnicianId.value = value ?? '',
                  decoration: const InputDecoration(labelText: 'Assigned technician'),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submit,
                child: Text(controller.existingCustomer == null ? 'Save Customer' : 'Update Customer'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
