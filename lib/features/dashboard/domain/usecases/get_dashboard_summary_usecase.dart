import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../users/domain/entities/app_user.dart';
import '../entities/dashboard_summary.dart';

class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(this._customersRepository);

  final CustomersRepository _customersRepository;

  Future<DashboardSummary> call(AppUser currentUser) async {
    final customers = await _customersRepository.getCustomers(currentUser);
    return DashboardSummary(totalCustomers: customers.length);
  }
}
