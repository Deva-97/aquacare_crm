import '../../../users/domain/entities/app_user.dart';
import '../entities/installation.dart';

abstract class InstallationsRepository {
  Future<List<Installation>> getInstallations(AppUser currentUser, {String? customerId});
  Future<Installation?> getInstallationById(String id);
  Future<void> saveInstallation(
    Installation installation,
    AppUser actor, {
    bool isUpdate = false,
  });
}
