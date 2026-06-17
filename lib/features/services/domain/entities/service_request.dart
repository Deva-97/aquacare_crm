class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.installationId,
    required this.serviceType,
    required this.complaintDescription,
    required this.status,
    required this.assignedTechnicianId,
    required this.scheduledDate,
    required this.completedDate,
    required this.amountCollected,
    required this.technicianNotes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String customerId;
  final String installationId;
  final String serviceType;
  final String complaintDescription;
  final String status;
  final String assignedTechnicianId;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final double amountCollected;
  final String technicianNotes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? installationId,
    String? serviceType,
    String? complaintDescription,
    String? status,
    String? assignedTechnicianId,
    DateTime? scheduledDate,
    DateTime? completedDate,
    double? amountCollected,
    String? technicianNotes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      installationId: installationId ?? this.installationId,
      serviceType: serviceType ?? this.serviceType,
      complaintDescription: complaintDescription ?? this.complaintDescription,
      status: status ?? this.status,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      amountCollected: amountCollected ?? this.amountCollected,
      technicianNotes: technicianNotes ?? this.technicianNotes,
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
      'installationId': installationId,
      'serviceType': serviceType,
      'complaintDescription': complaintDescription,
      'status': status,
      'assignedTechnicianId': assignedTechnicianId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'amountCollected': amountCollected,
      'technicianNotes': technicianNotes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      id: map['id'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      installationId: map['installationId'] as String? ?? '',
      serviceType: map['serviceType'] as String? ?? '',
      complaintDescription: map['complaintDescription'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      assignedTechnicianId: map['assignedTechnicianId'] as String? ?? '',
      scheduledDate: DateTime.tryParse(map['scheduledDate'] as String? ?? '') ?? DateTime.now(),
      completedDate: DateTime.tryParse(map['completedDate'] as String? ?? ''),
      amountCollected: (map['amountCollected'] as num? ?? 0).toDouble(),
      technicianNotes: map['technicianNotes'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
    );
  }
}
