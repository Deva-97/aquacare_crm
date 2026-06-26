class Customer {
  const Customer({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.address,
    required this.city,
    required this.pincode,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String customerName;
  final String mobileNumber;
  final String address;
  final String city;
  final String pincode;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Customer copyWith({
    String? id,
    String? customerName,
    String? mobileNumber,
    String? address,
    String? city,
    String? pincode,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      createdBy: createdBy ?? this.createdBy,
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
      'address': address,
      'city': city,
      'pincode': pincode,
      'createdBy': createdBy,
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
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
    );
  }
}
