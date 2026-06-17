import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/installations_controller.dart';

class InstallationsPage extends StatefulWidget {
  const InstallationsPage({super.key});

  @override
  State<InstallationsPage> createState() => _InstallationsPageState();
}

class _InstallationsPageState extends State<InstallationsPage> {
  late final InstallationsController controller;
  String? customerId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InstallationsController>();
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    customerId = args?['customerId'] as String?;
    controller.load(customerId: customerId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AppScaffold(
      title: 'Installation Details',
      floatingActionButton: auth.currentUser.value?.isTechnician == true
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.toNamed(
                  AppRoutes.installationForm,
                  arguments: <String, dynamic>{'customerId': customerId},
                );
                if (result == true) {
                  controller.load(customerId: customerId);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Installation'),
            ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.installations.isEmpty) {
          return const EmptyStateView(
            title: 'No installations yet',
            message: 'Installation records linked to visible customers will show here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.installations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final installation = controller.installations[index];
            return Card(
              child: ListTile(
                title: Text('${installation.filterBrand} ${installation.filterModel}'),
                subtitle: Text(
                  'Serial: ${installation.serialNumber}\nInstalled: ${AppDateUtils.formatDate(installation.installationDate)}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }
}
