import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class WaitingApprovalPage extends GetView<AuthController> {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              final user = controller.currentUser.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.pending_actions_outlined, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for owner approval',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user == null
                        ? 'Your account is not approved yet.'
                        : 'Signed in as ${user.email}. An owner needs to approve your account before you can access CRM data. This page will update automatically after approval.',
                    textAlign: TextAlign.center,
                  ),
                  if (controller.errorMessage.value.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshUser,
                    child: const Text('Refresh status'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.confirmSignOut,
                    child: const Text('Sign out'),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
