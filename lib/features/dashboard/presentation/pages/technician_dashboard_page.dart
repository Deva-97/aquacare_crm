import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class TechnicianDashboardPage extends GetView<DashboardController> {
  const TechnicianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: 'Aquacare CRM',
      actions: <Widget>[
        IconButton(
          onPressed: auth.confirmSignOut,
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const LoadingView();
        }
        final summary = controller.summary.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            _GradientStatCard(
              label: 'Customers',
              value: summary == null ? '—' : '${summary.totalCustomers}',
              icon: Icons.people_alt_outlined,
              onRefresh: controller.loadSummary,
            ),
            const SizedBox(height: 28),
            const _SectionLabel('QUICK ACTIONS'),
            const SizedBox(height: 12),
            _ActionCard(
              label: 'View Customers',
              subtitle: 'Browse customer records',
              icon: Icons.groups_outlined,
              iconColor: AppTheme.primary,
              onTap: () => Get.toNamed(AppRoutes.customers),
            ),
            _ActionCard(
              label: 'Manage Cities',
              subtitle: 'Add or remove cities in the dropdown',
              icon: Icons.location_city_outlined,
              iconColor: const Color(0xFF00838F),
              onTap: () => Get.toNamed(AppRoutes.manageCities),
            ),
          ],
        );
      }),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onRefresh,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 12, 22),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(
              Icons.refresh_outlined,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
