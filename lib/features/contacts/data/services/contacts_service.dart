import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as device_contacts;

import '../../../../core/utils/date_utils.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../installations/domain/entities/installation.dart';
import '../../domain/entities/contact_export_result.dart';

class ContactsService {
  static const int bulkCreateChunkSize = 250;

  Future<ContactsPermissionState> requestReadWritePermission() async {
    final device_contacts.PermissionStatus currentStatus =
        await device_contacts.FlutterContacts.permissions.check(
      device_contacts.PermissionType.readWrite,
    );
    if (_isGranted(currentStatus)) {
      return ContactsPermissionState.granted;
    }
    if (_isPermanentlyDenied(currentStatus)) {
      return ContactsPermissionState.permanentlyDenied;
    }
    if (currentStatus == device_contacts.PermissionStatus.restricted) {
      return ContactsPermissionState.restricted;
    }

    final device_contacts.PermissionStatus requestedStatus =
        await device_contacts.FlutterContacts.permissions.request(
      device_contacts.PermissionType.readWrite,
    );
    if (_isGranted(requestedStatus)) {
      return ContactsPermissionState.granted;
    }
    if (_isPermanentlyDenied(requestedStatus)) {
      return ContactsPermissionState.permanentlyDenied;
    }
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
      properties: <device_contacts.ContactProperty>{
        device_contacts.ContactProperty.phone,
      },
    );
    final Set<String> phoneNumbers = <String>{};
    for (final device_contacts.Contact contact in contacts) {
      for (final device_contacts.Phone phone in contact.phones) {
        final String normalized = normalizePhoneNumber(phone.number);
        if (normalized.isNotEmpty) {
          phoneNumbers.add(normalized);
        }
      }
    }
    return phoneNumbers;
  }

  Future<bool> contactExistsByMobileNumber(String mobileNumber) async {
    final String normalizedMobile = normalizePhoneNumber(mobileNumber);
    if (normalizedMobile.isEmpty) {
      return false;
    }

    try {
      final List<device_contacts.Contact> contacts =
          await device_contacts.FlutterContacts.getAll(
        properties: <device_contacts.ContactProperty>{
          device_contacts.ContactProperty.phone,
        },
        filter: device_contacts.ContactFilter.phone(mobileNumber),
      );
      return _contactsContainNumber(contacts, normalizedMobile);
    } catch (error, stackTrace) {
      debugPrint('Phone contact lookup failed, falling back to full scan: $error');
      debugPrintStack(stackTrace: stackTrace);
      final Set<String> existingPhoneNumbers = await getExistingPhoneNumbers();
      return existingPhoneNumbers.contains(normalizedMobile);
    }
  }

  Future<String> createCustomerContact(
    Customer customer, {
    Installation? installation,
  }) {
    return device_contacts.FlutterContacts.create(
      _buildContact(customer, installation: installation),
    );
  }

  Future<List<String>> createCustomerContacts(List<CustomerContactPayload> payloads) {
    return device_contacts.FlutterContacts.createAll(
      payloads
          .map(
            (CustomerContactPayload payload) => _buildContact(
              payload.customer,
              installation: payload.installation,
            ),
          )
          .toList(),
    );
  }

  static String normalizePhoneNumber(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  bool _contactsContainNumber(
    List<device_contacts.Contact> contacts,
    String normalizedMobile,
  ) {
    for (final device_contacts.Contact contact in contacts) {
      for (final device_contacts.Phone phone in contact.phones) {
        if (normalizePhoneNumber(phone.number) == normalizedMobile) {
          return true;
        }
      }
    }
    return false;
  }

  device_contacts.Contact _buildContact(
    Customer customer, {
    Installation? installation,
  }) {
    final String name = customer.customerName.trim().isEmpty
        ? 'Customer (Aquacare)'
        : '${customer.customerName.trim()} (Aquacare)';
    return device_contacts.Contact(
      name: device_contacts.Name(first: name),
      phones: _buildPhones(customer),
      addresses: _buildAddresses(customer),
      notes: <device_contacts.Note>[
        device_contacts.Note(
          note: _buildNotes(customer, installation: installation),
        ),
      ],
    );
  }

  List<device_contacts.Phone> _buildPhones(Customer customer) {
    final List<device_contacts.Phone> phones = <device_contacts.Phone>[];
    final Set<String> seen = <String>{};
    for (final String number in <String>[
      customer.mobileNumber,
      customer.whatsappNumber,
      customer.alternateMobileNumber,
    ]) {
      final String normalized = normalizePhoneNumber(number);
      if (normalized.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      phones.add(device_contacts.Phone(number: number.trim()));
    }
    return phones;
  }

  List<device_contacts.Address> _buildAddresses(Customer customer) {
    final String street = _joinNonEmpty(<String>[customer.address, customer.area]);
    final String city = customer.city.trim();
    final String postalCode = customer.pincode.trim();
    if (street.isEmpty && city.isEmpty && postalCode.isEmpty) {
      return const <device_contacts.Address>[];
    }
    return <device_contacts.Address>[
      device_contacts.Address(
        street: street,
        city: city,
        postalCode: postalCode,
      ),
    ];
  }

  String _buildNotes(
    Customer customer, {
    Installation? installation,
  }) {
    final String product = installation == null
        ? ''
        : _joinNonEmpty(<String>[installation.filterBrand, installation.filterModel], separator: ' ');
    final String installationDate = installation == null
        ? ''
        : AppDateUtils.formatDate(installation.installationDate);
    final String technician = installation?.installedBy.trim().isNotEmpty == true
        ? installation!.installedBy.trim()
        : customer.assignedTechnicianId.trim();

    return '''
Aquacare CRM Customer

Mobile:
${customer.mobileNumber.trim()}

WhatsApp:
${customer.whatsappNumber.trim()}

Address:
${_fullAddress(customer)}

Product:
$product

Installation Date:
$installationDate

Technician:
$technician

Notes:
${customer.notes.trim()}
'''.trim();
  }

  String _fullAddress(Customer customer) {
    final String cityLine = _joinNonEmpty(
      <String>[customer.city, customer.pincode],
      separator: ' ',
    );
    return _joinNonEmpty(<String>[customer.address, customer.area, cityLine]);
  }

  String _joinNonEmpty(List<String> values, {String separator = ', '}) {
    return values
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .join(separator);
  }

  bool _isGranted(device_contacts.PermissionStatus status) {
    return status == device_contacts.PermissionStatus.granted ||
        status == device_contacts.PermissionStatus.limited;
  }

  bool _isPermanentlyDenied(device_contacts.PermissionStatus status) {
    return status == device_contacts.PermissionStatus.permanentlyDenied;
  }
}

class CustomerContactPayload {
  const CustomerContactPayload({
    required this.customer,
    this.installation,
  });

  final Customer customer;
  final Installation? installation;
}
