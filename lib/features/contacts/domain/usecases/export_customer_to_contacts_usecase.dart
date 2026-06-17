import '../../../customers/domain/entities/customer.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../../installations/domain/repositories/installations_repository.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/contact_export_result.dart';
import '../repositories/contacts_repository.dart';

class ExportCustomerToContactsUseCase {
  ExportCustomerToContactsUseCase(
    this._contactsRepository,
    this._installationsRepository,
  );

  final ContactsRepository _contactsRepository;
  final InstallationsRepository _installationsRepository;

  Future<ContactExportResult> call({
    required Customer customer,
    required AppUser currentUser,
  }) async {
    final List<Installation> installations =
        await _installationsRepository.getInstallations(
      currentUser,
      customerId: customer.id,
    );
    return _contactsRepository.exportCustomer(
      customer,
      installation: _latestInstallation(installations),
    );
  }

  Future<void> openPermissionSettings() {
    return _contactsRepository.openPermissionSettings();
  }

  Installation? _latestInstallation(List<Installation> installations) {
    Installation? latest;
    for (final Installation installation in installations) {
      if (latest == null ||
          installation.installationDate.isAfter(latest.installationDate)) {
        latest = installation;
      }
    }
    return latest;
  }
}
