import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_constants.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

class TokenStorageService {
  // Kept only to remove values written by older app versions. New code never
  // reads or writes a password from secure storage.
  static const _legacyRememberedPasswordKey = 'remembered_password';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? accessTokenExpiresIn,
    int? refreshTokenExpiresIn,
  }) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    await _saveExpiry(
      AppConstants.keyAccessTokenExpiresAt,
      accessTokenExpiresIn,
    );
    await _saveExpiry(
      AppConstants.keyRefreshTokenExpiresAt,
      refreshTokenExpiresIn,
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyAccessTokenExpiresAt);
    await _storage.delete(key: AppConstants.keyRefreshTokenExpiresAt);
  }

  Future<DateTime?> getAccessTokenExpiry() =>
      _getExpiry(AppConstants.keyAccessTokenExpiresAt);

  Future<DateTime?> getRefreshTokenExpiry() =>
      _getExpiry(AppConstants.keyRefreshTokenExpiresAt);

  /// "Remember me" deliberately remembers only an email address. Sessions are
  /// restored with refresh tokens; a raw password must never be persisted.
  Future<void> saveRememberedEmail(String email) async {
    await _storage.write(key: AppConstants.keyRememberMe, value: 'true');
    await _storage.write(key: AppConstants.keyUserEmail, value: email);
    await _storage.delete(key: _legacyRememberedPasswordKey);
  }

  Future<void> clearRememberedEmail() async {
    await _storage.delete(key: AppConstants.keyRememberMe);
    await _storage.delete(key: AppConstants.keyUserEmail);
    await _storage.delete(key: _legacyRememberedPasswordKey);
  }

  Future<String?> getRememberedEmail() async {
    final rememberMe = await _storage.read(key: AppConstants.keyRememberMe);
    // Purge the legacy raw-password key on the first run after an upgrade.
    await _storage.delete(key: _legacyRememberedPasswordKey);
    if (rememberMe != 'true') return null;
    return _storage.read(key: AppConstants.keyUserEmail);
  }

  Future<bool> isRememberMeEnabled() async {
    await _storage.delete(key: _legacyRememberedPasswordKey);
    return (await _storage.read(key: AppConstants.keyRememberMe)) == 'true';
  }

  Future<void> saveLanguage(String lang) async {
    await _storage.write(key: AppConstants.keyLanguage, value: lang);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: AppConstants.keyLanguage);
  }

  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: AppConstants.keyApiBaseUrl, value: url);
  }

  Future<String> getBaseUrl() async {
    final custom = await _storage.read(key: AppConstants.keyApiBaseUrl);
    return custom ?? AppConstants.defaultBaseUrl;
  }

  Future<void> _saveExpiry(String key, int? expiresInSeconds) async {
    if (expiresInSeconds == null || expiresInSeconds <= 0) {
      await _storage.delete(key: key);
      return;
    }
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;
    await _storage.write(key: key, value: expiresAt.toString());
  }

  Future<DateTime?> _getExpiry(String key) async {
    final raw = await _storage.read(key: key);
    final millis = raw == null ? null : int.tryParse(raw);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
