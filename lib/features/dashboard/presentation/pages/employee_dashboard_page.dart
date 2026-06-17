import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class EmployeeDashboardPage extends GetView<DashboardController> {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return AppScaffold(
      title: 'Employee Dashboard',
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
              title: 'My Customers',
              value: '${summary.totalCustomers}',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'My Installations',
              value: '${summary.totalInstallations}',
              icon: Icons.build_outlined,
            ),
            const SizedBox(height: 20),
            _DashboardAction(
              label: 'My Customers',
              icon: Icons.groups_2_outlined,
              onTap: () => Get.toNamed(AppRoutes.customers),
            ),
            _DashboardAction(
              label: 'Add Installation',
              icon: Icons.add_home_outlined,
              onTap: () => Get.toNamed(AppRoutes.installationForm),
            ),
          ],
        );
      }),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }
}
