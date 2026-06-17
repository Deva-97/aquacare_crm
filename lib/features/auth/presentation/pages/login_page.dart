import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/loading_view.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingView(message: 'Signing you in...');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.water_drop_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aquacare CRM',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage customers, installations, and service jobs with offline-first sync.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.signIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                  ),
                  if (controller.errorMessage.value.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
