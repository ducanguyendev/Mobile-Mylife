import '../../../shared/utils/app_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String role;
  final int authProvider;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    required this.role,
    this.authProvider = 0,
    this.isActive = true,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (email.contains('@')) {
      final prefix = email.split('@')[0];
      if (prefix.isNotEmpty) return prefix;
    }
    return email.isNotEmpty ? email : 'User';
  }

  String get initials {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      }
      final name = fullName!.trim();
      if (name.length >= 2) return name.substring(0, 2).toUpperCase();
      return name.substring(0, 1).toUpperCase();
    }
    final clean = email.trim();
    if (clean.length >= 2) return clean.substring(0, 2).toUpperCase();
    if (clean.isNotEmpty) return clean.toUpperCase();
    return 'U';
  }

  String? get fullAvatarUrl {
    if (avatarUrl == null || avatarUrl!.trim().isEmpty || avatarUrl == 'none') return null;
    final url = avatarUrl!.trim();

    // 1. Chuyển đổi link Google Drive web view thành link ảnh trực tiếp Google CDN (lh3.googleusercontent.com/d/{id})
    if (url.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) {
        final fileId = match.group(1);
        final ts = url.contains('?t=') ? url.substring(url.indexOf('?t=')) : '';
        return 'https://lh3.googleusercontent.com/d/$fileId$ts';
      }
    } else if (url.contains('drive.google.com') && url.contains('id=')) {
      final match = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) {
        final fileId = match.group(1);
        final ts = url.contains('?t=') ? url.substring(url.indexOf('?t=')) : '';
        return 'https://lh3.googleusercontent.com/d/$fileId$ts';
      }
    }

    // 2. Link ảnh Google CDN hoặc link web trực tiếp
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final host = AppConstants.defaultBaseUrl.replaceAll('/api', '');
    return '$host$url';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawFullName = json['fullName'] as String?;
    final rawName = json['name'] as String?;
    final emailVal = (json['email'] as String?) ?? '';

    // Nếu fullName rỗng hoặc null, fallback sang name từ backend hoặc prefix từ email
    String? resolvedName = (rawFullName != null && rawFullName.trim().isNotEmpty)
        ? rawFullName.trim()
        : (rawName != null && rawName.trim().isNotEmpty)
            ? rawName.trim()
            : (emailVal.contains('@') ? emailVal.split('@')[0] : null);

    return UserModel(
      id: json['id'] ?? json['userId'] ?? '',
      email: emailVal,
      fullName: resolvedName,
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'Member',
      authProvider: json['authProvider'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'avatarUrl': avatarUrl,
      'role': role,
      'authProvider': authProvider,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      authProvider: authProvider,
      isActive: isActive ?? this.isActive,
    );
  }
}
