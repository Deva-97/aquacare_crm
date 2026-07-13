import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
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
    final bool isTechnician = auth.currentUser.value?.isTechnician == true;
    final bool isOwner = auth.currentUser.value?.isOwner == true;
    final String? currentUid = auth.currentUser.value?.uid;
    return AppScaffold(
      title: 'Customers',
      floatingActionButton: isTechnician
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.customerForm);
                if (result == true) controller.loadCustomers();
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Customer'),
            ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name, mobile, city or pincode',
              ),
              onChanged: controller.updateSearch,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();
              if (controller.customers.isEmpty) {
                return const EmptyStateView(
                  title: 'No customers yet',
                  message: 'Customers you add will appear here.',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadCustomers,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: controller.customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final Customer c = controller.customers[index];
                    return _CustomerCard(
                      customer: c,
                      canEdit: isOwner || (!isTechnician && c.createdBy == currentUid),
                      canDelete: isOwner,
                      onEdit: () async {
                        final result = await Get.toNamed(AppRoutes.customerForm, arguments: c);
                        if (result == true) controller.loadCustomers();
                      },
                      onDelete: () async {
                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Customer'),
                            content: Text('Delete "${c.customerName}"? This cannot be undone.'),
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
                        if (confirmed == true) await controller.delete(c);
                      },
                      onTap: () => Get.toNamed(AppRoutes.customerDetail, arguments: c),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final Customer customer;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  customer.customerName.isNotEmpty
                      ? customer.customerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      customer.customerName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.mobileNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (customer.city.isNotEmpty)
                      Text(
                        '${customer.city}${customer.pincode.isNotEmpty ? ' - ${customer.pincode}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  if (canEdit)
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  if (canDelete)
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
