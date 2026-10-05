class UserModel {
  static const roleAdmin = 'ADMIN';
  static const roleUser = 'USER';

  final int id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;
  final String role;
  final int authProvider;
  final bool hasLocalLogin;
  final bool hasGoogleLogin;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    required this.role,
    this.authProvider = 0,
    this.hasLocalLogin = true,
    this.hasGoogleLogin = false,
    this.isActive = true,
  });

  bool get isAdmin => role == roleAdmin;

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

  /// Resolves a raw avatar path against the active API host supplied by the
  /// caller. The model intentionally has no dependency on app configuration.
  String? avatarUrlForBase(String baseUrl) {
    if (avatarUrl == null || avatarUrl!.trim().isEmpty || avatarUrl == 'none') {
      return null;
    }
    final url = _normaliseGoogleDriveUrl(avatarUrl!.trim());
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final apiUri = Uri.tryParse(baseUrl);
    if (apiUri == null || !apiUri.hasScheme || !apiUri.hasAuthority) {
      return null;
    }
    final origin = Uri.parse('${apiUri.scheme}://${apiUri.authority}/');
    return origin.resolve(url).toString();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = _string(json['email']) ?? '';
    final fullName =
        _nonEmptyString(json['fullName']) ?? _nonEmptyString(json['name']);
    final authProvider = _intOrDefault(json['authProvider']);
    final providers = json['loginProviders'];
    final hasProviderFlags = providers is Map;
    return UserModel(
      id: _requiredInt(json['id'] ?? json['userId']),
      email: email,
      fullName:
          fullName ?? (email.contains('@') ? email.split('@').first : null),
      phoneNumber: _nullableString(json['phoneNumber']),
      gender: _nullableString(json['gender']),
      dateOfBirth: _nullableString(json['dateOfBirth']),
      avatarUrl: _nullableString(json['avatarUrl']),
      role: normalizeRole(json['role']),
      authProvider: authProvider,
      hasLocalLogin: hasProviderFlags
          ? _boolOrDefault(providers['local'])
          : authProvider != 1,
      hasGoogleLogin: hasProviderFlags
          ? _boolOrDefault(providers['google'])
          : authProvider == 1,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'avatarUrl': avatarUrl,
        'role': role,
        'authProvider': authProvider,
        'loginProviders': {
          'local': hasLocalLogin,
          'google': hasGoogleLogin,
        },
        'isActive': isActive,
      };

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
      role: role == null ? this.role : normalizeRole(role),
      authProvider: authProvider,
      hasLocalLogin: hasLocalLogin,
      hasGoogleLogin: hasGoogleLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  static String normalizeRole(dynamic value) {
    return _string(value)?.trim().toUpperCase() == roleAdmin
        ? roleAdmin
        : roleUser;
  }

  static int _requiredInt(dynamic value) {
    final parsed = _intOrNull(value);
    if (parsed == null) {
      throw const FormatException('User id is missing or invalid.');
    }
    return parsed;
  }

  static int _intOrDefault(dynamic value, [int fallback = 0]) =>
      _intOrNull(value) ?? fallback;

  static bool _boolOrDefault(dynamic value, [bool fallback = false]) =>
      value is bool ? value : fallback;

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _string(dynamic value) =>
      value is String ? value : value?.toString();

  static String? _nullableString(dynamic value) {
    final result = _string(value)?.trim();
    return result == null || result.isEmpty ? null : result;
  }

  static String? _nonEmptyString(dynamic value) => _nullableString(value);

  static String _normaliseGoogleDriveUrl(String url) {
    if (url.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) {
        final timestamp =
            url.contains('?t=') ? url.substring(url.indexOf('?t=')) : '';
        return 'https://lh3.googleusercontent.com/d/${match.group(1)}$timestamp';
      }
    }
    if (url.contains('drive.google.com') && url.contains('id=')) {
      final match = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) {
        final timestamp =
            url.contains('?t=') ? url.substring(url.indexOf('?t=')) : '';
        return 'https://lh3.googleusercontent.com/d/${match.group(1)}$timestamp';
      }
    }
    return url;
  }
}
