import 'package:get/get.dart';

class AppDataRefreshService extends GetxService {
  final RxInt customersRevision = 0.obs;
  final RxInt installationsRevision = 0.obs;
  final RxInt servicesRevision = 0.obs;
  final RxInt dashboardRevision = 0.obs;
  final RxInt auditLogsRevision = 0.obs;

  void notifyCustomersChanged() {
    customersRevision.value++;
    dashboardRevision.value++;
  }

  void notifyInstallationsChanged() {
    installationsRevision.value++;
    dashboardRevision.value++;
  }

  void notifyServicesChanged() {
    servicesRevision.value++;
    dashboardRevision.value++;
  }

  void notifyAuditLogsChanged() {
    auditLogsRevision.value++;
  }
}
