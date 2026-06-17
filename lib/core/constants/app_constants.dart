class AppConstants {
  const AppConstants._();

  static const String usersCollection = 'users';
  static const String customersCollection = 'customers';
  static const String installationsCollection = 'installations';
  static const String serviceRequestsCollection = 'service_requests';
  static const String auditLogsCollection = 'audit_logs';
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

  static const String operationCreate = 'create';
  static const String operationUpdate = 'update';
  static const String operationDelete = 'delete';

  static const List<String> customerTypes = <String>[
    'home',
    'shop',
    'office',
    'apartment',
    'commercial',
  ];

  static const List<String> filterTypes = <String>[
    'RO',
    'UV',
    'UF',
    'RO+UV',
    'Commercial RO',
  ];

  static const List<String> paymentStatuses = <String>[
    'paid',
    'pending',
    'partial',
  ];

  static const List<String> serviceTypes = <String>[
    'installation',
    'regular_service',
    'filter_change',
    'repair',
    'complaint',
  ];

  static const List<String> serviceStatuses = <String>[
    'pending',
    'assigned',
    'in_progress',
    'completed',
    'cancelled',
  ];
}
