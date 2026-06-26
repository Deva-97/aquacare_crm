import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../contacts/domain/entities/contact_export_result.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Export to Contacts',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Obx(() {
              final bool isExporting = controller.isExportingContacts.value;
              return ListTile(
                leading: isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.contacts_outlined),
                title: const Text('Export All Customers to Contacts'),
                subtitle: const Text('Creates Android contacts and skips existing mobile numbers.'),
                trailing: const Icon(Icons.chevron_right),
                enabled: !isExporting,
                onTap: isExporting ? null : () => _startExport(context),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _startExport(BuildContext context) async {
    _showProgressDialog(context);
    final ContactBatchExportResult? result =
        await controller.exportAllCustomersToContacts();
    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
    if (result != null) {
      _showSummaryDialog(result);
    }
  }

  void _showProgressDialog(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Exporting Contacts'),
        content: Obx(() {
          final ContactBatchExportProgress? progress =
              controller.exportProgress.value;
          final int total = progress?.total ?? 0;
          final int processed = progress?.processed ?? 0;
          final double? progressValue = total == 0 ? null : progress!.progress;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LinearProgressIndicator(value: progressValue),
              const SizedBox(height: 16),
              Text('$processed of $total customers processed'),
              if (progress != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Exported: ${progress.exported}  Skipped: ${progress.skipped}  Failed: ${progress.failed}',
                ),
              ],
            ],
          );
        }),
      ),
      barrierDismissible: false,
    );
  }

  void _showSummaryDialog(ContactBatchExportResult result) {
    final bool permissionBlocked = result.permissionState != ContactsPermissionState.granted;
    Get.dialog<void>(
      AlertDialog(
        title: Text(permissionBlocked ? 'Contacts Permission Required' : 'Export Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (permissionBlocked) ...<Widget>[
              Text(_permissionMessage(result.permissionState)),
              const SizedBox(height: 16),
            ],
            Text('Total: ${result.total}'),
            Text('Exported: ${result.exported}'),
            Text('Skipped: ${result.skipped}'),
            Text('Failed: ${result.failed}'),
            if (result.errors.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text('${result.errors.length} error(s) logged during export.'),
            ],
          ],
        ),
        actions: <Widget>[
          if (result.permissionState == ContactsPermissionState.permanentlyDenied)
            TextButton(
              onPressed: () {
                Get.back<void>();
                controller.openContactsPermissionSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: Get.back<void>,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _permissionMessage(ContactsPermissionState state) {
    switch (state) {
      case ContactsPermissionState.granted:
        return '';
      case ContactsPermissionState.denied:
        return 'Contacts permission was denied. Please allow contacts access and try again.';
      case ContactsPermissionState.permanentlyDenied:
        return 'Contacts permission is permanently denied. Enable it from Android app settings.';
      case ContactsPermissionState.restricted:
        return 'Contacts access is restricted on this device.';
    }
  }
}
