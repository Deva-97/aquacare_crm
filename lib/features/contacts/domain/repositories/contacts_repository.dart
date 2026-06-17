import '../../../customers/domain/entities/customer.dart';
import '../../../installations/domain/entities/installation.dart';
import '../entities/contact_export_result.dart';

abstract class ContactsRepository {
  Future<ContactExportResult> exportCustomer(
    Customer customer, {
    Installation? installation,
  });

  Future<ContactBatchExportResult> exportCustomers(
    List<Customer> customers, {
    required Map<String, Installation> latestInstallationsByCustomerId,
    void Function(ContactBatchExportProgress progress)? onProgress,
  });

  Future<void> openPermissionSettings();
}
