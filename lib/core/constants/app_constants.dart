class AppConstants {
  const AppConstants._();

  static const String usersCollection = 'users';
  static const String customersCollection = 'customers';
  static const String citiesCollection = 'cities';
  static const String systemCollection = 'system';
  static const String bootstrapDocument = 'bootstrap';

  static const String ownerRole = 'owner';
  static const String employeeRole = 'employee';
  static const String technicianRole = 'technician';
  static const String pendingRole = 'pending';

  static const String approvedStatus = 'approved';
  static const String pendingStatus = 'pending';
  static const String blockedStatus = 'blocked';

  static const String approvalNotificationChannelId = 'approval_requests';
  static const String approvalNotificationChannelName = 'Approval Requests';
  static const String approvalNotificationChannelDescription =
      'Alerts owners when new users are waiting for approval.';
}
