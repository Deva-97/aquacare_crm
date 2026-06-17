import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/service_request.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceRequest service = Get.arguments as ServiceRequest;
    final auth = Get.find<AuthController>();
    final bool technicianMode = auth.currentUser.value?.isTechnician == true;
    return AppScaffold(
      title: 'Service Detail',
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            final result = await Get.toNamed(
              AppRoutes.serviceForm,
              arguments: <String, dynamic>{
                'service': service,
                'technicianMode': technicianMode,
              },
            );
            if (result == true) {
              Get.back();
            }
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          service.serviceType.replaceAll('_', ' '),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      StatusChip(label: service.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Scheduled: ${AppDateUtils.formatDate(service.scheduledDate)}'),
                  Text('Completed: ${AppDateUtils.formatDate(service.completedDate)}'),
                  Text('Amount collected: ${service.amountCollected.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  Text('Complaint: ${service.complaintDescription}'),
                  const SizedBox(height: 8),
                  Text('Technician notes: ${service.technicianNotes.isEmpty ? '-' : service.technicianNotes}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
