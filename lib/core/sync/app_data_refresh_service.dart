import 'package:get/get.dart';

class AppDataRefreshService extends GetxService {
  final RxInt customersRevision = 0.obs;
  final RxInt dashboardRevision = 0.obs;

  void notifyCustomersChanged() {
    customersRevision.value++;
    dashboardRevision.value++;
  }
}
