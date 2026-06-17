class DashboardSummary {
  const DashboardSummary({
    required this.totalCustomers,
    required this.totalInstallations,
    required this.totalServices,
    required this.pendingServices,
  });

  final int totalCustomers;
  final int totalInstallations;
  final int totalServices;
  final int pendingServices;
}
