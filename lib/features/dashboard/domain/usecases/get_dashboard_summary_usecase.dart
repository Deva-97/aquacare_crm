import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../installations/domain/repositories/installations_repository.dart';
import '../../../services/domain/repositories/services_repository.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/dashboard_summary.dart';

class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(
    this._customersRepository,
    this._installationsRepository,
    this._servicesRepository,
  );

  final CustomersRepository _customersRepository;
  final InstallationsRepository _installationsRepository;
  final ServicesRepository _servicesRepository;

  Future<DashboardSummary> call(AppUser currentUser) async {
    final services = await _servicesRepository.getServices(currentUser);
    final customers = currentUser.isTechnician
        ? const []
        : await _customersRepository.getCustomers(currentUser);
    final installations = currentUser.isTechnician
        ? const []
        : await _installationsRepository.getInstallations(currentUser);
    final pendingServices = services.where((service) => service.status != 'completed').length;
    return DashboardSummary(
      totalCustomers: customers.length,
      totalInstallations: installations.length,
      totalServices: services.length,
      pendingServices: pendingServices,
    );
  }
}
