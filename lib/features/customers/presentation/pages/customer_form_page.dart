import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../controllers/customer_form_controller.dart';

class CustomerFormPage extends GetView<CustomerFormController> {
  const CustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: controller.existingCustomer == null ? 'Add Customer' : 'Edit Customer',
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _SectionLabel('Customer Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),

            ),
            const SizedBox(height: 16),
            Obx(() {
              final status = controller.mobileStatus.value;
              return TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  counterText: '',
                  suffixIcon: _MobileStatusIcon(status),
                ),
                onChanged: controller.onMobileChanged,
                validator: (v) {
                  final err = controller.validateMobile(v);
                  if (err != null) return err;
                  if (controller.mobileStatus.value == 'taken') {
                    return 'This number is already registered';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.addressController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.home_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              minLines: 2,

            ),
            const SizedBox(height: 16),
            Obx(() {
              final List<String> cities = controller.availableCities;
              if (cities.isEmpty) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'City',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    errorText: 'No cities available — go to Manage Cities to add some.',
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                  child: const SizedBox(height: 20),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Autocomplete<String>(
                    initialValue: TextEditingValue(text: controller.selectedCity.value ?? ''),
                    optionsBuilder: (TextEditingValue value) => controller.filterCities(value.text),
                    onSelected: controller.onCitySelected,
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          hintText: 'Search cities',
                          prefixIcon: Icon(Icons.location_city_outlined),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: controller.onCityTextChanged,
                        validator: (v) => controller.validateCity(v),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: options.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('No matching cities'),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final String option = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          title: Text(option),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                prefixIcon: Icon(Icons.pin_drop_outlined),
                counterText: '',
              ),
            ),
            const SizedBox(height: 28),
            Obx(() => FilledButton(
              onPressed: controller.isLoading.value ? null : controller.submit,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      controller.existingCustomer == null ? 'Save Customer' : 'Update Customer',
                      style: const TextStyle(fontSize: 16),
                    ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _MobileStatusIcon extends StatelessWidget {
  const _MobileStatusIcon(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'checking':
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case 'available':
        return const Icon(Icons.check_circle_outline, color: Colors.green);
      case 'taken':
        return Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error);
      default:
        return const SizedBox.shrink();
    }
  }
}
