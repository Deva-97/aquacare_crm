import '../../../customers/domain/entities/customer.dart';
import '../entities/contact_export_result.dart';

abstract class ContactsRepository {
  Future<ContactBatchExportResult> exportCustomers(
    List<Customer> customers, {
    void Function(ContactBatchExportProgress progress)? onProgress,
  });

  Future<void> openPermissionSettings();
}
