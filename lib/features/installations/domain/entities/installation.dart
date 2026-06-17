class Installation {
  const Installation({
    required this.id,
    required this.customerId,
    required this.filterBrand,
    required this.filterModel,
    required this.serialNumber,
    required this.filterType,
    required this.installationDate,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.installedBy,
    required this.paymentStatus,
    required this.amountCollected,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String customerId;
  final String filterBrand;
  final String filterModel;
  final String serialNumber;
  final String filterType;
  final DateTime installationDate;
  final DateTime warrantyStartDate;
  final DateTime warrantyEndDate;
  final String installedBy;
  final String paymentStatus;
  final double amountCollected;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Installation copyWith({
    String? id,
    String? customerId,
    String? filterBrand,
    String? filterModel,
    String? serialNumber,
    String? filterType,
    DateTime? installationDate,
    DateTime? warrantyStartDate,
    DateTime? warrantyEndDate,
    String? installedBy,
    String? paymentStatus,
    double? amountCollected,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Installation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      filterBrand: filterBrand ?? this.filterBrand,
      filterModel: filterModel ?? this.filterModel,
      serialNumber: serialNumber ?? this.serialNumber,
      filterType: filterType ?? this.filterType,
      installationDate: installationDate ?? this.installationDate,
      warrantyStartDate: warrantyStartDate ?? this.warrantyStartDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      installedBy: installedBy ?? this.installedBy,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountCollected: amountCollected ?? this.amountCollected,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'filterBrand': filterBrand,
      'filterModel': filterModel,
      'serialNumber': serialNumber,
      'filterType': filterType,
      'installationDate': installationDate.toIso8601String(),
      'warrantyStartDate': warrantyStartDate.toIso8601String(),
      'warrantyEndDate': warrantyEndDate.toIso8601String(),
      'installedBy': installedBy,
      'paymentStatus': paymentStatus,
      'amountCollected': amountCollected,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Installation.fromMap(Map<String, dynamic> map) {
    return Installation(
      id: map['id'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      filterBrand: map['filterBrand'] as String? ?? '',
      filterModel: map['filterModel'] as String? ?? '',
      serialNumber: map['serialNumber'] as String? ?? '',
      filterType: map['filterType'] as String? ?? '',
      installationDate: DateTime.tryParse(map['installationDate'] as String? ?? '') ?? DateTime.now(),
      warrantyStartDate: DateTime.tryParse(map['warrantyStartDate'] as String? ?? '') ?? DateTime.now(),
      warrantyEndDate: DateTime.tryParse(map['warrantyEndDate'] as String? ?? '') ?? DateTime.now(),
      installedBy: map['installedBy'] as String? ?? '',
      paymentStatus: map['paymentStatus'] as String? ?? 'pending',
      amountCollected: (map['amountCollected'] as num? ?? 0).toDouble(),
      notes: map['notes'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
    );
  }
}
