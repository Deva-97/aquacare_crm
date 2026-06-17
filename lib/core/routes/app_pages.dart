import 'package:get/get.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/waiting_approval_page.dart';
import '../notifications/approval_notification_service.dart';
import '../../features/customers/domain/usecases/customers_usecases.dart';
import '../../features/contacts/domain/usecases/export_all_customers_to_contacts_usecase.dart';
import '../../features/contacts/domain/usecases/export_customer_to_contacts_usecase.dart';
import '../../features/customers/presentation/controllers/customer_form_controller.dart';
import '../../features/customers/presentation/controllers/customer_details_controller.dart';
import '../../features/customers/presentation/controllers/customers_controller.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/domain/usecases/get_audit_logs_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../features/dashboard/presentation/controllers/audit_logs_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/dashboard/presentation/pages/audit_logs_page.dart';
import '../../features/dashboard/presentation/pages/employee_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/owner_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/technician_dashboard_page.dart';
import '../../features/installations/domain/usecases/installations_usecases.dart';
import '../../features/installations/presentation/controllers/installation_form_controller.dart';
import '../../features/installations/presentation/controllers/installations_controller.dart';
import '../../features/installations/presentation/pages/installation_form_page.dart';
import '../../features/installations/presentation/pages/installations_page.dart';
import '../../features/services/domain/usecases/services_usecases.dart';
import '../../features/services/presentation/controllers/service_form_controller.dart';
import '../../features/services/presentation/controllers/services_controller.dart';
import '../../features/services/presentation/pages/service_detail_page.dart';
import '../../features/services/presentation/pages/service_form_page.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/users/domain/usecases/users_usecases.dart';
import '../../features/users/presentation/controllers/users_controller.dart';
import '../../features/users/presentation/pages/user_management_page.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashPage.new,
      binding: BindingsBuilder(() {
        Get.put<AuthController>(
          AuthController(
            Get.find<GetCurrentUserUseCase>(),
            Get.find<WatchCurrentUserUseCase>(),
            Get.find<RefreshCurrentUserUseCase>(),
            Get.find<SignInWithGoogleUseCase>(),
            Get.find<SignOutUseCase>(),
            Get.find<ApprovalNotificationService>(),
          ),
          permanent: true,
        );
      }),
    ),
    GetPage(name: AppRoutes.login, page: LoginPage.new),
    GetPage(name: AppRoutes.waitingApproval, page: WaitingApprovalPage.new),
    GetPage(
      name: AppRoutes.ownerDashboard,
      page: OwnerDashboardPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(
          () => DashboardController(
            Get.find<GetDashboardSummaryUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: EmployeeDashboardPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(
          () => DashboardController(
            Get.find<GetDashboardSummaryUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.technicianDashboard,
      page: TechnicianDashboardPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(
          () => DashboardController(
            Get.find<GetDashboardSummaryUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: CustomersPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(
          () => CustomersController(
            Get.find<GetCustomersUseCase>(),
            Get.find<DeleteCustomerUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.customerDetail,
      page: CustomerDetailPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<InstallationsController>(
          () => InstallationsController(
            Get.find<GetInstallationsUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
        Get.lazyPut<CustomerDetailsController>(
          () => CustomerDetailsController(
            Get.find<ExportCustomerToContactsUseCase>(),
            Get.find<AuthController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.customerForm,
      page: CustomerFormPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerFormController>(
          () => CustomerFormController(
            Get.find<SaveCustomerUseCase>(),
            Get.find<CheckDuplicateCustomerUseCase>(),
            Get.find<FindSameNameCustomersUseCase>(),
            Get.find<ExportCustomerToContactsUseCase>(),
            Get.find<GetUsersUseCase>(),
            Get.find<AuthController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.installations,
      page: InstallationsPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<InstallationsController>(
          () => InstallationsController(
            Get.find<GetInstallationsUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.installationForm,
      page: InstallationFormPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<InstallationFormController>(
          () => InstallationFormController(
            Get.find<SaveInstallationUseCase>(),
            Get.find<GetCustomersUseCase>(),
            Get.find<AuthController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.services,
      page: ServicesPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<ServicesController>(
          () => ServicesController(
            Get.find<GetServicesUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(name: AppRoutes.serviceDetail, page: ServiceDetailPage.new),
    GetPage(
      name: AppRoutes.serviceForm,
      page: ServiceFormPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<ServiceFormController>(
          () => ServiceFormController(
            Get.find<SaveServiceUseCase>(),
            Get.find<UpdateTechnicianServiceUseCase>(),
            Get.find<GetCustomersUseCase>(),
            Get.find<GetInstallationsUseCase>(),
            Get.find<GetUsersUseCase>(),
            Get.find<AuthController>(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.userManagement,
      page: UserManagementPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<UsersController>(
          () => UsersController(
            Get.find<GetUsersUseCase>(),
            Get.find<GetPendingUsersUseCase>(),
            Get.find<ApproveUserUseCase>(),
            Get.find<UpdateUserUseCase>(),
            Get.find<AuthController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.auditLogs,
      page: AuditLogsPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<AuditLogsController>(
          () => AuditLogsController(Get.find<GetAuditLogsUseCase>()),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsScreen.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(
          () => SettingsController(
            Get.find<ExportAllCustomersToContactsUseCase>(),
            Get.find<AuthController>(),
          ),
        );
      }),
    ),
  ];
}
