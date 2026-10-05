import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/services/session_events.dart';
import '../../../shared/services/token_storage_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../models/auth_requests.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import 'auth_state.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authApiServiceProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return AuthNotifier(authService, tokenStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authService;
  final TokenStorageService _tokenStorage;

  AuthNotifier(this._authService, this._tokenStorage)
      : super(const AuthState()) {
    SessionEventBus.addListener(handleSessionExpired);
    unawaited(checkAuth());
  }

  @override
  void dispose() {
    SessionEventBus.removeListener(handleSessionExpired);
    super.dispose();
  }

  Future<void> handleSessionExpired() async {
    if (state.status == AuthStatus.unauthenticated && state.user == null) {
      return;
    }
    await _tokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);

    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.error,
        content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// The server is the source of truth on app startup. The interceptor will
  /// rotate a valid refresh token once if the access token has expired.
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _authService.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (error, stackTrace) {
      debugPrint('Session verification failed: $error\n$stackTrace');
      // The interceptor clears invalid sessions and emits the one session
      // expiration event. A transient startup failure remains retryable.
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password, rememberMe: rememberMe),
      );
      final accessToken = _requiredToken(response, 'accessToken');
      final refreshToken = _requiredToken(response, 'refreshToken');
      final responseUser = _userFromResponse(response);

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresIn: _intOrNull(response['accessTokenExpiresIn']),
        refreshTokenExpiresIn: _intOrNull(response['refreshTokenExpiresIn']),
      );
      if (rememberMe) {
        await _tokenStorage.saveRememberedEmail(email.trim());
      } else {
        await _tokenStorage.clearRememberedEmail();
      }

      UserModel user = responseUser;
      try {
        user = await _authService.getMe();
      } catch (error, stackTrace) {
        // The authenticated response contains the current user; retain it for
        // this session and let the next normal request verify with /api/me.
        debugPrint(
            'Post-login session verification failed: $error\n$stackTrace');
      }
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Local login failed: $error\n$stackTrace');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: ApiError.message(
          error,
          fallback: 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
        ),
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    if (idToken.trim().isEmpty) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Google did not provide a valid ID token.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response =
          await _authService.loginWithGoogleIdToken(idToken.trim());
      final accessToken = _requiredToken(response, 'accessToken');
      final refreshToken = _requiredToken(response, 'refreshToken');
      final responseUser = _userFromResponse(response);
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresIn: _intOrNull(response['accessTokenExpiresIn']),
        refreshTokenExpiresIn: _intOrNull(response['refreshTokenExpiresIn']),
      );

      UserModel user = responseUser;
      try {
        user = await _authService.getMe();
      } catch (error, stackTrace) {
        debugPrint(
            'Post-Google-login session verification failed: $error\n$stackTrace');
      }
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Google login failed: $error\n$stackTrace');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: ApiError.message(
          error,
          fallback: 'Đăng nhập với Google thất bại. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.register(request);
      return await login(request.email, request.password, false);
    } catch (error, stackTrace) {
      debugPrint('Registration failed: $error\n$stackTrace');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: ApiError.message(
          error,
          fallback: 'Đăng ký không thành công. Vui lòng thử lại.',
        ),
      );
      return false;
    }
  }

  /// Attempts server-side revocation first, but always removes local secrets.
  /// This lets the user safely sign out even while offline.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    try {
      await _authService.logout(refreshToken);
      // A 401-triggered refresh may finish while the first logout request is
      // in flight. Revoke the rotated token too before local storage is wiped.
      final rotatedRefreshToken = await _tokenStorage.getRefreshToken();
      if (rotatedRefreshToken != null &&
          rotatedRefreshToken.isNotEmpty &&
          rotatedRefreshToken != refreshToken) {
        await _authService.logout(rotatedRefreshToken);
      }
    } catch (error, stackTrace) {
      debugPrint(
          'Remote logout failed; clearing local session: $error\n$stackTrace');
    } finally {
      await _tokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearError() {
    if (state.errorMessage != null) state = state.copyWith(clearError: true);
  }

  void updateAvatarLocally(String avatarUrl) {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(avatarUrl: avatarUrl));
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final updatedUser = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      state = state.copyWith(user: updatedUser, clearError: true);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Profile update failed: $error\n$stackTrace');
      state = state.copyWith(
        errorMessage: ApiError.message(
          error,
          fallback: 'Unable to update your profile. Please try again.',
        ),
      );
      return false;
    }
  }

  static String _requiredToken(Map<String, dynamic> response, String key) {
    final value = response[key]?.toString();
    if (value == null || value.isEmpty) {
      throw FormatException('The server did not return $key.');
    }
    return value;
  }

  static UserModel _userFromResponse(Map<String, dynamic> response) {
    final rawUser = response['user'];
    if (rawUser is Map<String, dynamic>) return UserModel.fromJson(rawUser);
    if (rawUser is Map) {
      return UserModel.fromJson(
        rawUser.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    throw const FormatException('The server did not return a user profile.');
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
