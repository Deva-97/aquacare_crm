import '../constants/app_constants.dart';

class RoleUtils {
  const RoleUtils._();

  static bool isOwner(String? role) => role == AppConstants.ownerRole;
  static bool isEmployee(String? role) => role == AppConstants.employeeRole;
  static bool isTechnician(String? role) => role == AppConstants.technicianRole;
  static bool isApproved(String? status) => status == AppConstants.approvedStatus;
}
