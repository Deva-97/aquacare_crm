import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class TechnicianDashboardPage extends GetView<DashboardController> {
  const TechnicianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return AppScaffold(
      title: 'Technician Dashboard',
      actions: <Widget>[
        IconButton(onPressed: authController.confirmSignOut, icon: const Icon(Icons.logout)),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final summary = controller.summary.value;
        if (summary == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('No dashboard data available.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadSummary,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            InfoCard(
              title: 'Assigned Jobs',
              value: '${summary.totalServices}',
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Open Jobs',
              value: '${summary.pendingServices}',
              icon: Icons.pending_actions_outlined,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.services),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('View Assigned Service Jobs'),
            ),
          ],
        );
      }),
    );
  }
}
