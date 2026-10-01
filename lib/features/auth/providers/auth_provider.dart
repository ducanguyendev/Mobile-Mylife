import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
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
  Timer? _sessionTimer;

  AuthNotifier(this._authService, this._tokenStorage)
      : super(const AuthState()) {
    SessionEventBus.addListener(handleSessionExpired);
    checkAuth();
    _startSessionTimer();
  }

  @override
  void dispose() {
    SessionEventBus.removeListener(handleSessionExpired);
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (state.isAuthenticated) {
        final token = await _tokenStorage.getAccessToken();
        if (token != null && _isTokenExpired(token)) {
          try {
            await _authService.getMe();
          } catch (_) {
            // Khi getMe() lỗi và không refresh được token, AuthInterceptor sẽ gọi handleSessionExpired()
          }
        }
      }
    });
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(resp);
      if (map is Map && map['exp'] != null) {
        final exp = map['exp'] as int;
        return DateTime.now()
            .isAfter(DateTime.fromMillisecondsSinceEpoch(exp * 1000));
      }
    } catch (_) {}
    return false;
  }

  Future<void> handleSessionExpired() async {
    if (state.status == AuthStatus.unauthenticated && state.user == null) {
      return;
    }
    await _tokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);

    // Hiển thị thông báo hết phiên làm việc bình thường
    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.error,
        content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _tokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _authService.getMe();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final res = await _authService.login(
        LoginRequest(email: email, password: password, rememberMe: rememberMe),
      );

      final accessToken = res['accessToken'] as String;
      final refreshToken = res['refreshToken'] as String;

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      if (rememberMe) {
        await _tokenStorage.saveRememberedCredentials(
          email: email,
          password: password,
        );
      } else {
        await _tokenStorage.clearRememberedCredentials();
      }

      final userMap = (res['user'] as Map<String, dynamic>?) ?? res;
      if (userMap['email'] == null || (userMap['email'] as String).isEmpty) {
        userMap['email'] = email;
      }

      try {
        final fullUser = await _authService.getMe();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: fullUser,
        );
      } catch (_) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromJson(userMap),
        );
      }
      return true;
    } catch (e) {
      String msg = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle(String emailOrCode) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final res = await _authService.loginWithGoogle(emailOrCode);

      final accessToken = res['accessToken'] as String?;
      final refreshToken = res['refreshToken'] as String?;

      if (accessToken != null && refreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      if (res['email'] != null) {
        await _tokenStorage.saveUserEmail(res['email'] as String);
      }

      final userMap = (res['user'] as Map<String, dynamic>?) ?? res;
      try {
        final fullUser = await _authService.getMe();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: fullUser,
        );
      } catch (_) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromJson(userMap),
        );
      }
      return true;
    } catch (e) {
      String msg = 'Đăng nhập với Google thất bại. Vui lòng thử lại.';
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequest req) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _authService.register(req);
      // Đăng nhập tự động sau khi đăng ký
      return await login(req.email, req.password, false);
    } catch (e) {
      String msg = 'Đăng ký không thành công. Vui lòng thử lại.';
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void updateAvatarLocally(String avatarUrl) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(avatarUrl: avatarUrl),
      );
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
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
}
