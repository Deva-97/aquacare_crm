import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/customer.dart';

Future<void> _launchCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    Get.snackbar('Error', 'Could not open dialler for $phoneNumber',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments as Customer;
    final auth = Get.find<AuthController>();
    final bool canEdit = auth.currentUser.value?.isTechnician != true;

    return AppScaffold(
      title: 'Customer Detail',
      actions: <Widget>[
        if (canEdit)
          IconButton(
            onPressed: () async {
              final result =
                  await Get.toNamed(AppRoutes.customerForm, arguments: customer);
              if (result == true) Get.back();
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: <Widget>[
          _HeroCard(customer: customer),
          const SizedBox(height: 16),
          _DetailsCard(customer: customer),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.customer});

  final Customer customer;

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
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                customer.customerName.isNotEmpty
                    ? customer.customerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  customer.customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.phone_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SelectableText(
                        customer.mobileNumber,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchCall(customer.mobileNumber),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.call, color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            const Text(
                              'Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'CUSTOMER INFORMATION',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.home_outlined,
              label: 'Address',
              value: customer.address,
            ),
            const _Divider(),
            _DetailRow(
              icon: Icons.location_city_outlined,
              label: 'City',
              value: customer.city,
            ),
            if (customer.pincode.isNotEmpty) ...<Widget>[
              const _Divider(),
              _DetailRow(
                icon: Icons.pin_drop_outlined,
                label: 'Pincode',
                value: customer.pincode,
              ),
            ],
            const _Divider(),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Added on',
              value: AppDateUtils.formatDateTime(customer.createdAt),
            ),
            if (customer.updatedAt != customer.createdAt) ...<Widget>[
              const _Divider(),
              _DetailRow(
                icon: Icons.update_outlined,
                label: 'Last updated',
                value: AppDateUtils.formatDateTime(customer.updatedAt),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
