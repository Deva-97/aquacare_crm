import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/notifications/approval_notification_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class OwnerDashboardPage extends GetView<DashboardController> {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ApprovalNotificationService approvalNotificationService =
        Get.find<ApprovalNotificationService>();
    return AppScaffold(
      title: 'Owner Dashboard',
      actions: <Widget>[
        IconButton(
          onPressed: authController.confirmSignOut,
          icon: const Icon(Icons.logout),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const LoadingView();
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
            Obx(() {
              final int pendingCount = approvalNotificationService.pendingCount.value;
              if (pendingCount == 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text('$pendingCount user${pendingCount == 1 ? '' : 's'} waiting approval'),
                    subtitle: const Text('Tap to review the next pending approval request.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: approvalNotificationService.openNextPendingApproval,
                  ),
                ),
              );
            }),
            InfoCard(
              title: 'Customers',
              value: '${summary.totalCustomers}',
              icon: Icons.people_alt_outlined,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Installations',
              value: '${summary.totalInstallations}',
              icon: Icons.plumbing_outlined,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Pending Services',
              value: '${summary.pendingServices}',
              icon: Icons.build_circle_outlined,
            ),
            const SizedBox(height: 20),
            _MenuButton(
              label: 'Manage Customers',
              icon: Icons.groups_outlined,
              onTap: () => Get.toNamed(AppRoutes.customers),
            ),
            _MenuButton(
              label: 'Manage Installations',
              icon: Icons.water_damage_outlined,
              onTap: () => Get.toNamed(AppRoutes.installations),
            ),
            _MenuButton(
              label: 'Manage Service Requests',
              icon: Icons.support_agent_outlined,
              onTap: () => Get.toNamed(AppRoutes.services),
            ),
            _MenuButton(
              label: 'Approve Users and Roles',
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => Get.toNamed(AppRoutes.userManagement),
            ),
            _MenuButton(
              label: 'Audit Logs',
              icon: Icons.history_outlined,
              onTap: () => Get.toNamed(AppRoutes.auditLogs),
            ),
            _MenuButton(
              label: 'Settings',
              icon: Icons.settings_outlined,
              onTap: () => Get.toNamed(AppRoutes.settings),
            ),
          ],
        );
      }),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
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
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
