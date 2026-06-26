import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as device_contacts;

import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/contact_export_result.dart';

class ContactsService {
  static const int bulkCreateChunkSize = 250;

  Future<ContactsPermissionState> requestReadWritePermission() async {
    final device_contacts.PermissionStatus currentStatus =
        await device_contacts.FlutterContacts.permissions.check(
      device_contacts.PermissionType.readWrite,
    );
    if (_isGranted(currentStatus)) return ContactsPermissionState.granted;
    if (_isPermanentlyDenied(currentStatus)) return ContactsPermissionState.permanentlyDenied;
    if (currentStatus == device_contacts.PermissionStatus.restricted) {
      return ContactsPermissionState.restricted;
    }

    final device_contacts.PermissionStatus requestedStatus =
        await device_contacts.FlutterContacts.permissions.request(
      device_contacts.PermissionType.readWrite,
    );
    if (_isGranted(requestedStatus)) return ContactsPermissionState.granted;
    if (_isPermanentlyDenied(requestedStatus)) return ContactsPermissionState.permanentlyDenied;
    if (requestedStatus == device_contacts.PermissionStatus.restricted) {
      return ContactsPermissionState.restricted;
    }
    return ContactsPermissionState.denied;
  }

  Future<void> openPermissionSettings() {
    return device_contacts.FlutterContacts.permissions.openSettings();
  }

  Future<Set<String>> getExistingPhoneNumbers() async {
    final List<device_contacts.Contact> contacts =
        await device_contacts.FlutterContacts.getAll(
      properties: <device_contacts.ContactProperty>{device_contacts.ContactProperty.phone},
    );
    final Set<String> phoneNumbers = <String>{};
    for (final device_contacts.Contact contact in contacts) {
      for (final device_contacts.Phone phone in contact.phones) {
        final String normalized = normalizePhoneNumber(phone.number);
        if (normalized.isNotEmpty) phoneNumbers.add(normalized);
      }
    }
    return phoneNumbers;
  }

  Future<bool> contactExistsByMobileNumber(String mobileNumber) async {
    final String normalizedMobile = normalizePhoneNumber(mobileNumber);
    if (normalizedMobile.isEmpty) return false;
    try {
      final List<device_contacts.Contact> contacts =
          await device_contacts.FlutterContacts.getAll(
        properties: <device_contacts.ContactProperty>{device_contacts.ContactProperty.phone},
        filter: device_contacts.ContactFilter.phone(mobileNumber),
      );
      return _contactsContainNumber(contacts, normalizedMobile);
    } catch (error, stackTrace) {
      debugPrint('Phone contact lookup failed, falling back to full scan: $error');
      debugPrintStack(stackTrace: stackTrace);
      final Set<String> existing = await getExistingPhoneNumbers();
      return existing.contains(normalizedMobile);
    }
  }

  Future<String> createCustomerContact(Customer customer) {
    return device_contacts.FlutterContacts.create(_buildContact(customer));
  }

  Future<List<String>> createCustomerContacts(List<Customer> customers) {
    return device_contacts.FlutterContacts.createAll(
      customers.map(_buildContact).toList(),
    );
  }

  static String normalizePhoneNumber(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  bool _contactsContainNumber(List<device_contacts.Contact> contacts, String normalizedMobile) {
    for (final device_contacts.Contact contact in contacts) {
      for (final device_contacts.Phone phone in contact.phones) {
        if (normalizePhoneNumber(phone.number) == normalizedMobile) return true;
      }
    }
    return false;
  }

  device_contacts.Contact _buildContact(Customer customer) {
    final String name = customer.customerName.trim().isEmpty
        ? 'Customer (Aquacare)'
        : '${customer.customerName.trim()} (Aquacare)';
    return device_contacts.Contact(
      name: device_contacts.Name(first: name),
      phones: <device_contacts.Phone>[
        if (customer.mobileNumber.trim().isNotEmpty)
          device_contacts.Phone(number: customer.mobileNumber.trim()),
      ],
      addresses: _buildAddress(customer),
      notes: <device_contacts.Note>[
        device_contacts.Note(note: _buildNote(customer)),
      ],
    );
  }

  List<device_contacts.Address> _buildAddress(Customer customer) {
    final String street = customer.address.trim();
    final String city = customer.city.trim();
    final String postal = customer.pincode.trim();
    if (street.isEmpty && city.isEmpty && postal.isEmpty) return const [];
    return <device_contacts.Address>[
      device_contacts.Address(street: street, city: city, postalCode: postal),
    ];
  }

  String _buildNote(Customer customer) {
    final parts = <String>['Aquacare CRM Customer'];
    if (customer.mobileNumber.trim().isNotEmpty) {
      parts.add('Mobile: ${customer.mobileNumber.trim()}');
    }
    if (customer.address.trim().isNotEmpty) {
      parts.add('Address: ${customer.address.trim()}');
    }
    if (customer.city.trim().isNotEmpty) {
      final cityLine = customer.pincode.trim().isNotEmpty
          ? '${customer.city.trim()} - ${customer.pincode.trim()}'
          : customer.city.trim();
      parts.add('City: $cityLine');
    }
    return parts.join('\n');
  }

  bool _isGranted(device_contacts.PermissionStatus status) {
    return status == device_contacts.PermissionStatus.granted ||
        status == device_contacts.PermissionStatus.limited;
  }

  bool _isPermanentlyDenied(device_contacts.PermissionStatus status) {
    return status == device_contacts.PermissionStatus.permanentlyDenied;
  }
}
