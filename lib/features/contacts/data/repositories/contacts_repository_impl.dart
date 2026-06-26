import 'package:flutter/foundation.dart';

import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/contact_export_result.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../services/contacts_service.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._contactsService);

  final ContactsService _contactsService;

  @override
  Future<ContactBatchExportResult> exportCustomers(
    List<Customer> customers, {
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
      onProgress?.call(ContactBatchExportProgress(
        total: total,
        processed: processed,
        exported: exported,
        skipped: skipped,
        failed: failed,
      ));
    }

    emitProgress();
    final Set<String> seenPhoneNumbers = await _contactsService.getExistingPhoneNumbers();
    final List<Customer> pending = <Customer>[];

    for (final Customer customer in customers) {
      final String normalized = ContactsService.normalizePhoneNumber(customer.mobileNumber);
      if (normalized.isEmpty || seenPhoneNumbers.contains(normalized)) {
        skipped++;
        processed++;
        if (processed % 100 == 0 || processed == total) emitProgress();
        continue;
      }
      seenPhoneNumbers.add(normalized);
      pending.add(customer);
    }

    emitProgress();

    for (int start = 0; start < pending.length; start += ContactsService.bulkCreateChunkSize) {
      final int end = (start + ContactsService.bulkCreateChunkSize).clamp(0, pending.length);
      final List<Customer> chunk = pending.sublist(start, end);
      try {
        final List<String> ids = await _contactsService.createCustomerContacts(chunk);
        exported += ids.length;
        failed += chunk.length - ids.length;
        processed += chunk.length;
        emitProgress();
      } catch (error, stackTrace) {
        debugPrint('Bulk contact creation failed, retrying individually: $error');
        debugPrintStack(stackTrace: stackTrace);
        for (final Customer customer in chunk) {
          try {
            final bool exists = await _contactsService.contactExistsByMobileNumber(customer.mobileNumber);
            if (exists) {
              skipped++;
            } else {
              await _contactsService.createCustomerContact(customer);
              exported++;
            }
          } catch (e, st) {
            failed++;
            errors.add('${customer.customerName}: $e');
            debugPrint('Contact export failed for ${customer.id}: $e');
            debugPrintStack(stackTrace: st);
          }
          processed++;
          emitProgress();
        }
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
  Future<void> openPermissionSettings() => _contactsService.openPermissionSettings();
}
