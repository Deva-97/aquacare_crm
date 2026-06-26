class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;

  bool get isAdmin => role == 'owner';
  bool get isOwner => isAdmin; // kept for internal compatibility
  bool get isEmployee => role == 'employee';
  bool get isTechnician => role == 'technician';
  bool get isApproved => status == 'approved';

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'pending',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      approvedBy: map['approvedBy'] as String?,
    );
  }
}
