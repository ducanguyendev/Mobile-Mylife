import '../../auth/models/user_model.dart';

class AdminUserModel {
  final int id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const AdminUserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == UserModel.roleAdmin;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final id = _parseId(json['id']);
    return AdminUserModel(
      id: id,
      email: json['email']?.toString() ?? '',
      fullName: _nullableString(json['fullName']),
      phoneNumber: _nullableString(json['phoneNumber']),
      avatarUrl: _nullableString(json['avatarUrl']),
      role: UserModel.normalizeRole(json['role']),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const FormatException('Admin user id is missing or invalid.');
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
