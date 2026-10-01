import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_constants.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
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
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: AppConstants.keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConstants.keyUserEmail);
  }

  Future<void> saveRememberedCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: AppConstants.keyRememberMe, value: 'true');
    await _storage.write(key: AppConstants.keyUserEmail, value: email);
    await _storage.write(key: AppConstants.keyRememberedPassword, value: password);
  }

  Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: AppConstants.keyRememberMe);
    await _storage.delete(key: AppConstants.keyUserEmail);
    await _storage.delete(key: AppConstants.keyRememberedPassword);
  }

  Future<Map<String, dynamic>> getRememberedCredentials() async {
    final rememberMe = await _storage.read(key: AppConstants.keyRememberMe);
    if (rememberMe == 'true') {
      final email = await _storage.read(key: AppConstants.keyUserEmail);
      final password = await _storage.read(key: AppConstants.keyRememberedPassword);
      return {
        'rememberMe': true,
        'email': email ?? '',
        'password': password ?? '',
      };
    }
    return {
      'rememberMe': false,
      'email': '',
      'password': '',
    };
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
}
