import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/contact_actions_row.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../installations/presentation/controllers/installations_controller.dart';
import '../../domain/entities/customer.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late final Customer customer;
  late final InstallationsController installationsController;
  late final CustomerDetailsController customerDetailsController;

  @override
  void initState() {
    super.initState();
    customer = Get.arguments as Customer;
    installationsController = Get.find<InstallationsController>();
    customerDetailsController = Get.find<CustomerDetailsController>();
    installationsController.load(customerId: customer.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: 'Customer Detail',
      actions: <Widget>[
        if (auth.currentUser.value?.isTechnician != true)
          IconButton(
            onPressed: () async {
              final result = await Get.toNamed(
                AppRoutes.customerForm,
                arguments: customer,
              );
              if (result == true) {
                Get.back();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
      ],
      floatingActionButton: auth.currentUser.value?.isTechnician == true
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.toNamed(
                  AppRoutes.installationForm,
                  arguments: <String, dynamic>{'customerId': customer.id},
                );
                if (result == true) {
                  installationsController.load(customerId: customer.id);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Installation'),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    customer.customerName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(customer.address),
                  Text('${customer.area}, ${customer.city} ${customer.pincode}'),
                  const SizedBox(height: 8),
                  ContactActionsRow(
                    mobileNumber: customer.mobileNumber,
                    whatsappNumber: customer.whatsappNumber,
                  ),
                  const SizedBox(height: 8),
                  Text('Type: ${customer.customerType}'),
                  Text('Created: ${AppDateUtils.formatDate(customer.createdAt)}'),
                  if (customer.notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text('Notes: ${customer.notes}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final bool isExporting = customerDetailsController.isExportingContact.value;
            return ElevatedButton.icon(
              onPressed: isExporting
                  ? null
                  : () => customerDetailsController.exportToContacts(customer),
              icon: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.contacts_outlined),
              label: Text(isExporting ? 'Exporting...' : 'Export to Contacts'),
            );
          }),
          const SizedBox(height: 16),
          if (auth.currentUser.value?.isOwner == true)
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(
                AppRoutes.serviceForm,
                arguments: <String, dynamic>{'customerId': customer.id},
              ),
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Create Service Request'),
            ),
          const SizedBox(height: 16),
          Text('Installations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Obx(() {
            if (installationsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (installationsController.installations.isEmpty) {
              return const Text('No installation records available.');
            }
            return Column(
              children: installationsController.installations.map((installation) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text('${installation.filterBrand} ${installation.filterModel}'),
                      subtitle: Text(
                        '${installation.serialNumber}\nInstalled ${AppDateUtils.formatDate(installation.installationDate)}',
                      ),
                      isThreeLine: true,
                      onTap: () => Get.toNamed(
                        AppRoutes.installations,
                        arguments: <String, dynamic>{'customerId': customer.id},
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
