import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/contact_actions_row.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/customer.dart';
import '../controllers/customers_controller.dart';

class CustomersPage extends GetView<CustomersController> {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: auth.currentUser.value?.isOwner == true ? 'All Customers' : 'My Customers',
      floatingActionButton: auth.currentUser.value?.isTechnician == true
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.customerForm);
                if (result == true) {
                  controller.loadCustomers();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
            ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name, mobile, area, or serial number',
              ),
              onChanged: controller.updateSearch,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingView();
              }
              if (controller.customers.isEmpty) {
                return const EmptyStateView(
                  title: 'No customers yet',
                  message: 'Customers you create or manage will appear here.',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadCustomers,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: controller.customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final Customer customer = controller.customers[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              customer.customerName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('${customer.mobileNumber} - ${customer.area}, ${customer.city}'),
                            const SizedBox(height: 8),
                            ContactActionsRow(
                              mobileNumber: customer.mobileNumber,
                              whatsappNumber: customer.whatsappNumber,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                    AppRoutes.customerDetail,
                                    arguments: customer,
                                  ),
                                  child: const Text('View Details'),
                                ),
                                if (auth.currentUser.value?.isTechnician != true)
                                  TextButton(
                                    onPressed: () async {
                                      final result = await Get.toNamed(
                                        AppRoutes.customerForm,
                                        arguments: customer,
                                      );
                                      if (result == true) {
                                        controller.loadCustomers();
                                      }
                                    },
                                    child: const Text('Edit'),
                                  ),
                                if (auth.currentUser.value?.isOwner == true)
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                    onPressed: () async {
                                      final bool? confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext ctx) => AlertDialog(
                                          title: const Text('Delete Customer'),
                                          content: Text(
                                            'Are you sure you want to delete "${customer.customerName}"? '
                                            'This will also hide their installations and service records.',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Theme.of(ctx).colorScheme.error,
                                              ),
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await controller.delete(customer);
                                      }
                                    },
                                    child: const Text('Delete'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
