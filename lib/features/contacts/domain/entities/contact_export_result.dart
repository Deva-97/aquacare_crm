enum ContactsPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

enum ContactExportStatus {
  exported,
  skippedDuplicate,
  skippedInvalidMobile,
  permissionDenied,
  permissionPermanentlyDenied,
  permissionRestricted,
  failed,
}

class ContactExportResult {
  const ContactExportResult({
    required this.status,
    required this.message,
    this.contactId,
  });

  final ContactExportStatus status;
  final String message;
  final String? contactId;

  bool get isExported => status == ContactExportStatus.exported;
}

class ContactBatchExportProgress {
  const ContactBatchExportProgress({
    required this.total,
    required this.processed,
    required this.exported,
    required this.skipped,
    required this.failed,
  });

  final int total;
  final int processed;
  final int exported;
  final int skipped;
  final int failed;

  double get progress => total == 0 ? 0 : processed / total;
}

class ContactBatchExportResult extends ContactBatchExportProgress {
  const ContactBatchExportResult({
    required super.total,
    required super.processed,
    required super.exported,
    required super.skipped,
    required super.failed,
    this.permissionState = ContactsPermissionState.granted,
    this.errors = const <String>[],
  });

  final ContactsPermissionState permissionState;
  final List<String> errors;

  bool get hasPermission => permissionState == ContactsPermissionState.granted;
}
