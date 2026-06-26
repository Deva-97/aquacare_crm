import 'package:get/get.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/waiting_approval_page.dart';
import '../notifications/approval_notification_service.dart';
import '../../features/customers/domain/usecases/customers_usecases.dart';
import '../../features/customers/presentation/controllers/customer_form_controller.dart';
import '../../features/customers/presentation/controllers/customers_controller.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/dashboard/presentation/pages/employee_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/owner_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/technician_dashboard_page.dart';
import '../../features/contacts/domain/usecases/export_all_customers_to_contacts_usecase.dart';
import '../../features/customers/presentation/controllers/manage_cities_controller.dart';
import '../../features/customers/presentation/pages/manage_cities_page.dart';
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
    ),
    GetPage(
      name: AppRoutes.customerForm,
      page: CustomerFormPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerFormController>(
          () => CustomerFormController(
            Get.find<SaveCustomerUseCase>(),
            Get.find<CheckDuplicateMobileUseCase>(),
            Get.find<FindSameNameCustomersUseCase>(),
            Get.find<GetCitiesUseCase>(),
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
      name: AppRoutes.manageCities,
      page: ManageCitiesPage.new,
      binding: BindingsBuilder(() {
        Get.lazyPut<ManageCitiesController>(
          () => ManageCitiesController(
            Get.find<GetCitiesUseCase>(),
            Get.find<SaveCityUseCase>(),
            Get.find<DeleteCityUseCase>(),
          ),
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
