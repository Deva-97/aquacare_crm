import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/remote/firebase/firebase_auth_remote_data_source.dart';
import '../../data/remote/firebase/firestore_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../../features/contacts/data/services/contacts_service.dart';
import '../../features/contacts/domain/repositories/contacts_repository.dart';
import '../../features/contacts/domain/usecases/export_all_customers_to_contacts_usecase.dart';
import '../../features/contacts/domain/usecases/export_customer_to_contacts_usecase.dart';
import '../../features/customers/data/repositories/customers_repository_impl.dart';
import '../../features/customers/domain/repositories/customers_repository.dart';
import '../../features/customers/domain/usecases/customers_usecases.dart';
import '../../features/dashboard/domain/usecases/get_audit_logs_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../features/installations/data/repositories/installations_repository_impl.dart';
import '../../features/installations/domain/repositories/installations_repository.dart';
import '../../features/installations/domain/usecases/installations_usecases.dart';
import '../../features/services/data/repositories/services_repository_impl.dart';
import '../../features/services/domain/repositories/services_repository.dart';
import '../../features/services/domain/usecases/services_usecases.dart';
import '../../features/users/data/repositories/users_repository_impl.dart';
import '../../features/users/domain/repositories/users_repository.dart';
import '../../features/users/domain/usecases/users_usecases.dart';
import '../../firebase_options.dart';
import '../notifications/approval_notification_service.dart';
import '../sync/app_data_refresh_service.dart';

class AppBindings {
  const AppBindings._();

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Get.put<AppDataRefreshService>(
      AppDataRefreshService(),
      permanent: true,
    );

    Get.put<ContactsService>(ContactsService(), permanent: true);

    Get.put<FirebaseAuthRemoteDataSource>(
      FirebaseAuthRemoteDataSource(
        FirebaseAuth.instance,
        GoogleSignIn(serverClientId: DefaultFirebaseOptions.webClientId),
      ),
      permanent: true,
    );
    Get.put<FirestoreRemoteDataSource>(
      FirestoreRemoteDataSource(FirebaseFirestore.instance),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        Get.find<FirebaseAuthRemoteDataSource>(),
        Get.find<FirestoreRemoteDataSource>(),
      ),
      permanent: true,
    );
    Get.put<UsersRepository>(
      UsersRepositoryImpl(
        Get.find<FirestoreRemoteDataSource>(),
      ),
      permanent: true,
    );
    Get.put<CustomersRepository>(
      CustomersRepositoryImpl(
        Get.find<FirestoreRemoteDataSource>(),
      ),
      permanent: true,
    );
    Get.put<InstallationsRepository>(
      InstallationsRepositoryImpl(
        Get.find<FirestoreRemoteDataSource>(),
      ),
      permanent: true,
    );
    Get.put<ServicesRepository>(
      ServicesRepositoryImpl(
        Get.find<FirestoreRemoteDataSource>(),
      ),
      permanent: true,
    );
    Get.put<ContactsRepository>(
      ContactsRepositoryImpl(Get.find<ContactsService>()),
      permanent: true,
    );

    Get.put<GetCurrentUserUseCase>(GetCurrentUserUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put<WatchCurrentUserUseCase>(WatchCurrentUserUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put<RefreshCurrentUserUseCase>(RefreshCurrentUserUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put<SignOutUseCase>(SignOutUseCase(Get.find<AuthRepository>()), permanent: true);
    Get.put<GetUsersUseCase>(GetUsersUseCase(Get.find<UsersRepository>()), permanent: true);
    Get.put<GetPendingUsersUseCase>(GetPendingUsersUseCase(Get.find<UsersRepository>()), permanent: true);
    Get.put<GetUserByIdUseCase>(GetUserByIdUseCase(Get.find<UsersRepository>()), permanent: true);
    Get.put<ApproveUserUseCase>(ApproveUserUseCase(Get.find<UsersRepository>()), permanent: true);
    Get.put<UpdateUserUseCase>(UpdateUserUseCase(Get.find<UsersRepository>()), permanent: true);
    Get.put<GetCustomersUseCase>(GetCustomersUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<GetCustomerByIdUseCase>(GetCustomerByIdUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<SaveCustomerUseCase>(SaveCustomerUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<DeleteCustomerUseCase>(DeleteCustomerUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<CheckDuplicateCustomerUseCase>(CheckDuplicateCustomerUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<FindSameNameCustomersUseCase>(FindSameNameCustomersUseCase(Get.find<CustomersRepository>()), permanent: true);
    Get.put<ExportCustomerToContactsUseCase>(
      ExportCustomerToContactsUseCase(
        Get.find<ContactsRepository>(),
        Get.find<InstallationsRepository>(),
      ),
      permanent: true,
    );
    Get.put<ExportAllCustomersToContactsUseCase>(
      ExportAllCustomersToContactsUseCase(
        Get.find<ContactsRepository>(),
        Get.find<CustomersRepository>(),
        Get.find<InstallationsRepository>(),
      ),
      permanent: true,
    );
    Get.put<GetInstallationsUseCase>(GetInstallationsUseCase(Get.find<InstallationsRepository>()), permanent: true);
    Get.put<GetInstallationByIdUseCase>(GetInstallationByIdUseCase(Get.find<InstallationsRepository>()), permanent: true);
    Get.put<SaveInstallationUseCase>(SaveInstallationUseCase(Get.find<InstallationsRepository>()), permanent: true);
    Get.put<GetServicesUseCase>(GetServicesUseCase(Get.find<ServicesRepository>()), permanent: true);
    Get.put<GetServiceByIdUseCase>(GetServiceByIdUseCase(Get.find<ServicesRepository>()), permanent: true);
    Get.put<SaveServiceUseCase>(SaveServiceUseCase(Get.find<ServicesRepository>()), permanent: true);
    Get.put<UpdateTechnicianServiceUseCase>(UpdateTechnicianServiceUseCase(Get.find<ServicesRepository>()), permanent: true);
    Get.put<GetDashboardSummaryUseCase>(
      GetDashboardSummaryUseCase(
        Get.find<CustomersRepository>(),
        Get.find<InstallationsRepository>(),
        Get.find<ServicesRepository>(),
      ),
      permanent: true,
    );
    Get.put<GetAuditLogsUseCase>(GetAuditLogsUseCase(Get.find<ServicesRepository>()), permanent: true);

    Get.put<ApprovalNotificationService>(
      await ApprovalNotificationService(
        FlutterLocalNotificationsPlugin(),
        Get.find<FirestoreRemoteDataSource>(),
        Get.find<ApproveUserUseCase>(),
        Get.find<UpdateUserUseCase>(),
      ).init(),
      permanent: true,
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {}
}
