import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../domain/entities/contact_export_result.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../services/contacts_service.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._contactsService);

  final ContactsService _contactsService;

  @override
  Future<ContactExportResult> exportCustomer(
    Customer customer, {
    Installation? installation,
  }) async {
    try {
      final ContactsPermissionState permissionState =
          await _contactsService.requestReadWritePermission();
      final ContactExportResult? permissionResult =
          _permissionResultForSingle(permissionState);
      if (permissionResult != null) {
        return permissionResult;
      }

      final String normalizedMobile =
          ContactsService.normalizePhoneNumber(customer.mobileNumber);
      if (normalizedMobile.isEmpty) {
        return const ContactExportResult(
          status: ContactExportStatus.skippedInvalidMobile,
          message: 'Customer does not have a valid mobile number.',
        );
      }

      final bool exists =
          await _contactsService.contactExistsByMobileNumber(customer.mobileNumber);
      if (exists) {
        return const ContactExportResult(
          status: ContactExportStatus.skippedDuplicate,
          message: 'A contact with this mobile number already exists.',
        );
      }

      final String contactId = await _contactsService.createCustomerContact(
        customer,
        installation: installation,
      );
      return ContactExportResult(
        status: ContactExportStatus.exported,
        message: 'Customer exported to contacts.',
        contactId: contactId,
      );
    } catch (error, stackTrace) {
      debugPrint('Single contact export failed for customer ${customer.id}: $error');
      debugPrintStack(stackTrace: stackTrace);
      return ContactExportResult(
        status: ContactExportStatus.failed,
        message: _readableError(error),
      );
    }
  }

  @override
  Future<ContactBatchExportResult> exportCustomers(
    List<Customer> customers, {
    required Map<String, Installation> latestInstallationsByCustomerId,
    void Function(ContactBatchExportProgress progress)? onProgress,
  }) async {
    final ContactsPermissionState permissionState =
        await _contactsService.requestReadWritePermission();
    if (permissionState != ContactsPermissionState.granted) {
      final ContactBatchExportResult result = ContactBatchExportResult(
        total: customers.length,
        processed: 0,
        exported: 0,
        skipped: 0,
        failed: 0,
        permissionState: permissionState,
      );
      onProgress?.call(result);
      return result;
    }

    final int total = customers.length;
    int processed = 0;
    int exported = 0;
    int skipped = 0;
    int failed = 0;
    final List<String> errors = <String>[];

    void emitProgress() {
      onProgress?.call(
        ContactBatchExportProgress(
          total: total,
          processed: processed,
          exported: exported,
          skipped: skipped,
          failed: failed,
        ),
      );
    }

    emitProgress();
    final Set<String> seenPhoneNumbers = await _contactsService.getExistingPhoneNumbers();
    final List<CustomerContactPayload> pendingContacts = <CustomerContactPayload>[];

    for (final Customer customer in customers) {
      final String normalizedMobile =
          ContactsService.normalizePhoneNumber(customer.mobileNumber);
      if (normalizedMobile.isEmpty || seenPhoneNumbers.contains(normalizedMobile)) {
        skipped++;
        processed++;
        if (processed % 100 == 0 || processed == total) {
          emitProgress();
        }
        continue;
      }

      seenPhoneNumbers.add(normalizedMobile);
      pendingContacts.add(
        CustomerContactPayload(
          customer: customer,
          installation: latestInstallationsByCustomerId[customer.id],
        ),
      );
    }

    emitProgress();

    for (int start = 0; start < pendingContacts.length; start += ContactsService.bulkCreateChunkSize) {
      final int end = (start + ContactsService.bulkCreateChunkSize).clamp(0, pendingContacts.length);
      final List<CustomerContactPayload> chunk = pendingContacts.sublist(start, end);
      try {
        final List<String> ids = await _contactsService.createCustomerContacts(chunk);
        exported += ids.length;
        failed += chunk.length - ids.length;
        processed += chunk.length;
        emitProgress();
      } catch (error, stackTrace) {
        debugPrint('Bulk contact creation failed, retrying individually: $error');
        debugPrintStack(stackTrace: stackTrace);
        final _ChunkFallbackResult fallbackResult = await _createChunkIndividually(chunk);
        exported += fallbackResult.exported;
        skipped += fallbackResult.skipped;
        failed += fallbackResult.failed;
        processed += chunk.length;
        errors.addAll(fallbackResult.errors);
        emitProgress();
      }
    }

    return ContactBatchExportResult(
      total: total,
      processed: processed,
      exported: exported,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
  }

  @override
  Future<void> openPermissionSettings() {
    return _contactsService.openPermissionSettings();
  }

  Future<_ChunkFallbackResult> _createChunkIndividually(
    List<CustomerContactPayload> chunk,
  ) async {
    int exported = 0;
    int skipped = 0;
    int failed = 0;
    final List<String> errors = <String>[];

    for (final CustomerContactPayload payload in chunk) {
      try {
        final bool exists = await _contactsService.contactExistsByMobileNumber(
          payload.customer.mobileNumber,
        );
        if (exists) {
          skipped++;
          continue;
        }
        await _contactsService.createCustomerContact(
          payload.customer,
          installation: payload.installation,
        );
        exported++;
      } catch (error, stackTrace) {
        failed++;
        final String message = _readableError(error);
        errors.add('${payload.customer.customerName}: $message');
        debugPrint('Contact export failed for customer ${payload.customer.id}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return _ChunkFallbackResult(
      exported: exported,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
  }

  ContactExportResult? _permissionResultForSingle(
    ContactsPermissionState permissionState,
  ) {
    switch (permissionState) {
      case ContactsPermissionState.granted:
        return null;
      case ContactsPermissionState.denied:
        return const ContactExportResult(
          status: ContactExportStatus.permissionDenied,
          message: 'Contacts permission was denied.',
        );
      case ContactsPermissionState.permanentlyDenied:
        return const ContactExportResult(
          status: ContactExportStatus.permissionPermanentlyDenied,
          message: 'Contacts permission is permanently denied. Enable it in app settings.',
        );
      case ContactsPermissionState.restricted:
        return const ContactExportResult(
          status: ContactExportStatus.permissionRestricted,
          message: 'Contacts access is restricted on this device.',
        );
    }
  }

  String _readableError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
}

class _ChunkFallbackResult {
  const _ChunkFallbackResult({
    required this.exported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });

  final int exported;
  final int skipped;
  final int failed;
  final List<String> errors;
}
