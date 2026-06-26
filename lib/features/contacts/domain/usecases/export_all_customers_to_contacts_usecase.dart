import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/contact_export_result.dart';
import '../repositories/contacts_repository.dart';

class ExportAllCustomersToContactsUseCase {
  ExportAllCustomersToContactsUseCase(
    this._contactsRepository,
    this._customersRepository,
  );

  final ContactsRepository _contactsRepository;
  final CustomersRepository _customersRepository;

  Future<ContactBatchExportResult> call({
    required AppUser currentUser,
    void Function(ContactBatchExportProgress progress)? onProgress,
  }) async {
    final customers = await _customersRepository.getCustomers(currentUser);
    return _contactsRepository.exportCustomers(customers, onProgress: onProgress);
  }

  Future<void> openPermissionSettings() => _contactsRepository.openPermissionSettings();
}
