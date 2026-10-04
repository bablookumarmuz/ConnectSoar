enum UserRole { admin, manager, employee }

enum UserStatus { online, busy, away, offline }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final UserRole role;
  final UserStatus status;
  final String statusText;
  final String department;
  final String designation;
  final String? phone;
  final bool resetPassword;
  final String? createdAt;
  final String? updatedAt;
  final bool isEmailVerified;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    String? avatarUrl,
    required this.role,
    this.status = UserStatus.online,
    this.statusText = 'active',
    this.department = 'Engineering',
    this.designation = 'Team Member',
    String? title,
    this.phone,
    this.resetPassword = false,
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified = true,
  });

  /// Backwards compatibility getter for avatarUrl
  String get avatarUrl => imageUrl ?? '';

  /// Backwards compatibility getter for title
  String get title => designation;

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? 'employee').toLowerCase();
    final statusRaw = (json['status'] as String? ?? 'active').toLowerCase();

    UserRole mappedRole;
    switch (roleStr) {
      case 'admin':
        mappedRole = UserRole.admin;
        break;
      case 'manager':
        mappedRole = UserRole.manager;
        break;
      case 'employee':
      default:
        mappedRole = UserRole.employee;
        break;
    }

    UserStatus mappedStatus = UserStatus.online;
    if (statusRaw == 'inactive' || statusRaw == 'offline') {
      mappedStatus = UserStatus.offline;
    } else if (statusRaw == 'busy') {
      mappedStatus = UserStatus.busy;
    } else if (statusRaw == 'away') {
      mappedStatus = UserStatus.away;
    }

    // Support both snake_case (real API) and camelCase (legacy)
    final imgUrl = json['image_url'] as String? ?? json['avatarUrl'] as String?;
    final dept = json['department'] as String? ?? 'Engineering';
    final desig =
        json['designation'] as String? ??
        json['title'] as String? ??
        'Team Member';
    final phoneNum = json['phone'] as String?;
    final isReset = json['reset_password'] as bool? ?? false;
    final created = json['created_at'] as String?;
    final updated = json['updated_at'] as String?;

    return UserModel(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageUrl: imgUrl,
      role: mappedRole,
      status: mappedStatus,
      statusText: statusRaw,
      department: dept,
      designation: desig,
      phone: phoneNum,
      resetPassword: isReset,
      createdAt: created,
      updatedAt: updated,
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'status': statusText,
      'department': department,
      'designation': designation,
      'title': title,
      'phone': phone,
      'reset_password': resetPassword,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    UserRole? role,
    UserStatus? status,
    String? statusText,
    String? department,
    String? designation,
    String? phone,
    bool? resetPassword,
    String? createdAt,
    String? updatedAt,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      resetPassword: resetPassword ?? this.resetPassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
