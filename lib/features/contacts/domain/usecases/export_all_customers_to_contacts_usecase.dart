import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../../installations/domain/repositories/installations_repository.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/contact_export_result.dart';
import '../repositories/contacts_repository.dart';

class ExportAllCustomersToContactsUseCase {
  ExportAllCustomersToContactsUseCase(
    this._contactsRepository,
    this._customersRepository,
    this._installationsRepository,
  );

  final ContactsRepository _contactsRepository;
  final CustomersRepository _customersRepository;
  final InstallationsRepository _installationsRepository;

  Future<ContactBatchExportResult> call({
    required AppUser currentUser,
    void Function(ContactBatchExportProgress progress)? onProgress,
  }) async {
    final List<Customer> customers =
        await _customersRepository.getCustomers(currentUser);
    final Set<String> customerIds = customers.map((Customer customer) => customer.id).toSet();
    final List<Installation> installations =
        await _installationsRepository.getInstallations(currentUser);
    return _contactsRepository.exportCustomers(
      customers,
      latestInstallationsByCustomerId: _latestInstallationsByCustomerId(
        installations,
        customerIds,
      ),
      onProgress: onProgress,
    );
  }

  Future<void> openPermissionSettings() {
    return _contactsRepository.openPermissionSettings();
  }

  Map<String, Installation> _latestInstallationsByCustomerId(
    List<Installation> installations,
    Set<String> customerIds,
  ) {
    final Map<String, Installation> latestByCustomerId = <String, Installation>{};
    for (final Installation installation in installations) {
      if (!customerIds.contains(installation.customerId)) {
        continue;
      }
      final Installation? existing = latestByCustomerId[installation.customerId];
      if (existing == null ||
          installation.installationDate.isAfter(existing.installationDate)) {
        latestByCustomerId[installation.customerId] = installation;
      }
    }
    return latestByCustomerId;
  }
}
