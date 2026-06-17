class Customer {
  const Customer({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.alternateMobileNumber,
    required this.address,
    required this.area,
    required this.city,
    required this.pincode,
    required this.customerType,
    required this.notes,
    required this.createdBy,
    required this.assignedEmployeeId,
    required this.assignedTechnicianId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String customerName;
  final String mobileNumber;
  final String whatsappNumber;
  final String alternateMobileNumber;
  final String address;
  final String area;
  final String city;
  final String pincode;
  final String customerType;
  final String notes;
  final String createdBy;
  final String assignedEmployeeId;
  final String assignedTechnicianId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Customer copyWith({
    String? id,
    String? customerName,
    String? mobileNumber,
    String? whatsappNumber,
    String? alternateMobileNumber,
    String? address,
    String? area,
    String? city,
    String? pincode,
    String? customerType,
    String? notes,
    String? createdBy,
    String? assignedEmployeeId,
    String? assignedTechnicianId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      alternateMobileNumber: alternateMobileNumber ?? this.alternateMobileNumber,
      address: address ?? this.address,
      area: area ?? this.area,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      customerType: customerType ?? this.customerType,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'whatsappNumber': whatsappNumber,
      'alternateMobileNumber': alternateMobileNumber,
      'address': address,
      'area': area,
      'city': city,
      'pincode': pincode,
      'customerType': customerType,
      'notes': notes,
      'createdBy': createdBy,
      'assignedEmployeeId': assignedEmployeeId,
      'assignedTechnicianId': assignedTechnicianId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      whatsappNumber: map['whatsappNumber'] as String? ?? '',
      alternateMobileNumber: map['alternateMobileNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      area: map['area'] as String? ?? '',
      city: map['city'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      customerType: map['customerType'] as String? ?? 'home',
      notes: map['notes'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      assignedEmployeeId: map['assignedEmployeeId'] as String? ?? '',
      assignedTechnicianId: map['assignedTechnicianId'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
    );
  }
}
