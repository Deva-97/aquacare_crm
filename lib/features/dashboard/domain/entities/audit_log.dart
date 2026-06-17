class AuditLog {
  const AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.performedBy,
    required this.oldValue,
    required this.newValue,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String performedBy;
  final String oldValue;
  final String newValue;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'performedBy': performedBy,
      'oldValue': oldValue,
      'newValue': newValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String? ?? '',
      action: map['action'] as String? ?? '',
      entityType: map['entityType'] as String? ?? '',
      entityId: map['entityId'] as String? ?? '',
      performedBy: map['performedBy'] as String? ?? '',
      oldValue: map['oldValue'] as String? ?? '',
      newValue: map['newValue'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
