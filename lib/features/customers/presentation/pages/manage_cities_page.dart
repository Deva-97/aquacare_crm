import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../controllers/manage_cities_controller.dart';

class ManageCitiesPage extends GetView<ManageCitiesController> {
  const ManageCitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Manage Cities',
      body: Column(
        children: <Widget>[
          // ── Search / add city bar ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: theme.colorScheme.surface,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller.addController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Search or add a city',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: controller.onSearchChanged,
                    onSubmitted: (_) => controller.addCity(),
                  ),
                ),
                Obx(() {
                  if (controller.hasExactMatch) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: FilledButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.addCity,
                      child: const Text('Add'),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Cities list ─────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.cities.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.cities.isEmpty) {
                return const EmptyStateView(
                  title: 'No cities yet',
                  message:
                      'Add city names here. Employees will see these as a dropdown when entering customer data.',
                );
              }
              final List<String> filtered = controller.filteredCities;
              if (filtered.isEmpty) {
                return EmptyStateView(
                  title: 'No matching cities',
                  message:
                      '"${controller.query.value.trim()}" isn\'t in the list yet. Tap Add to create it.',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadCities,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final String city = filtered[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            city[0].toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          city,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: 'Remove city',
                          onPressed: () => _confirmDelete(context, city),
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

  Future<void> _confirmDelete(BuildContext context, String city) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove City'),
        content: Text(
          'Remove "$city" from the dropdown list?\n\n'
          'Existing customer records with this city will not be affected.',
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteCity(city);
    }
  }
}
