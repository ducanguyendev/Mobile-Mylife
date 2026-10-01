class AppConstants {
  // Đổi IP ở đây khi test trên thiết bị thật (ví dụ: http://192.168.1.10:5274/api)
  // 10.0.2.2 dùng cho Android Emulator truy cập localhost máy host
  static const String defaultBaseUrl = 'http://10.0.2.2:5274/api';

  static const String appTitle = 'MyLife Portfolio & Security';
  static const String appVersion = '1.0.0';

  // Google OAuth 2.0 Config
  static const String googleClientId = '924945270776-5esfnr0teb8bn7ifeub92kr8kf9qakru.apps.googleusercontent.com';
  static const String googleRedirectUri = 'http://localhost:5173';

  // Storage Keys
  static const String keyAccessToken = 'jwt_access_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyUserEmail = 'saved_user_email';
  static const String keyRememberMe = 'remember_me';
  static const String keyRememberedPassword = 'remembered_password';
  static const String keyLanguage = 'app_language';
  static const String keyApiBaseUrl = 'custom_api_base_url';
}
