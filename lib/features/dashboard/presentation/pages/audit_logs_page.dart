import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../controllers/audit_logs_controller.dart';

class AuditLogsPage extends GetView<AuditLogsController> {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Audit Logs',
      actions: <Widget>[
        IconButton(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.logs.isEmpty) {
          return const EmptyStateView(
            title: 'No audit logs yet',
            message: 'Owner-managed changes synced to Firestore will appear here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final log = controller.logs[index];
            return Card(
              child: ListTile(
                title: Text(log.action),
                subtitle: Text(
                  '${log.entityType} • ${log.entityId}\n${AppDateUtils.formatDateTime(log.createdAt)}',
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
