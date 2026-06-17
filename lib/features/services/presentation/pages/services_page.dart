import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/services_controller.dart';

class ServicesPage extends GetView<ServicesController> {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: auth.currentUser.value?.isTechnician == true ? 'Assigned Service Jobs' : 'Service Requests',
      floatingActionButton: auth.currentUser.value?.isOwner == true
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.serviceForm);
                if (result == true) {
                  controller.loadServices();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
            )
          : null,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.services.isEmpty) {
          return const EmptyStateView(
            title: 'No service jobs',
            message: 'Assigned or created service requests will show here.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadServices,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final service = controller.services[index];
              return Card(
                child: ListTile(
                  title: Text(service.serviceType.replaceAll('_', ' ')),
                  subtitle: Text(
                    'Status: ${service.status}\nScheduled: ${AppDateUtils.formatDate(service.scheduledDate)}',
                  ),
                  isThreeLine: true,
                  onTap: () => Get.toNamed(AppRoutes.serviceDetail, arguments: service),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
