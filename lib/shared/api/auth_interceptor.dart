import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/session_events.dart';
import '../services/token_storage_service.dart';
import 'api_endpoints.dart';

typedef SessionExpiredCallback = void Function();

/// Adds the access token and serializes refresh-token rotation.
///
/// A shared refresh future ensures that concurrent 401 responses either retry
/// after one token rotation or all fail cleanly; no request can be stranded in
/// a callback queue.
class AuthInterceptor extends Interceptor {
  final TokenStorageService _storage;
  final Dio _dio;
  final SessionExpiredCallback? onSessionExpired;

  Future<String>? _refreshFuture;
  bool _sessionExpiredNotified = false;

  AuthInterceptor(this._storage, this._dio, {this.onSessionExpired});

  static const _retryKey = 'auth_retry_attempted';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAbsoluteUrl(options.path)) {
      options.baseUrl = await _storage.getBaseUrl();
    }

    if (!_isPublicEndpoint(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        !_canRefresh(request) ||
        request.extra[_retryKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final accessToken = await _refreshAccessToken();
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.extra[_retryKey] = true;
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (error, stackTrace) {
      debugPrint('Token refresh failed; ending local session: $error\n$stackTrace');
      await _expireSessionOnce();
      handler.next(err);
    }
  }

  bool _canRefresh(RequestOptions options) {
    return !_isPublicEndpoint(options.path) &&
        !_matchesEndpoint(options.path, ApiEndpoints.refreshToken) &&
        !_matchesEndpoint(options.path, ApiEndpoints.logout);
  }

  bool _isPublicEndpoint(String path) {
    return _matchesEndpoint(path, ApiEndpoints.login) ||
        _matchesEndpoint(path, ApiEndpoints.register) ||
        _matchesEndpoint(path, ApiEndpoints.googleAuth) ||
        _matchesEndpoint(path, ApiEndpoints.refreshToken) ||
        _matchesEndpoint(path, ApiEndpoints.logout);
  }

  bool _matchesEndpoint(String path, String endpoint) {
    final uri = Uri.tryParse(path);
    final targetPath = uri?.hasScheme == true ? uri!.path : path;
    return targetPath == endpoint || targetPath.endsWith(endpoint);
  }

  bool _isAbsoluteUrl(String value) => Uri.tryParse(value)?.hasScheme == true;

  Future<String> _refreshAccessToken() {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;

    final refresh = _performRefresh();
    _refreshFuture = refresh;
    refresh.then<void>(
      (_) {
        if (identical(_refreshFuture, refresh)) _refreshFuture = null;
      },
      onError: (_, __) {
        if (identical(_refreshFuture, refresh)) _refreshFuture = null;
      },
    );
    return refresh;
  }

  Future<String> _performRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    final accessToken = await _storage.getAccessToken();
    if (refreshToken == null ||
        refreshToken.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      throw StateError('No refreshable session is available.');
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: await _storage.getBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'mobile',
          'X-Requested-With': 'MyLife',
        },
      ),
    );
    final response = await refreshDio.post<dynamic>(
      ApiEndpoints.refreshToken,
      data: {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      },
    );
    final data = response.data;
    if (data is! Map) throw StateError('Invalid refresh response.');
    final newAccessToken = data['accessToken']?.toString();
    final newRefreshToken = data['refreshToken']?.toString();
    if (newAccessToken == null ||
        newAccessToken.isEmpty ||
        newRefreshToken == null ||
        newRefreshToken.isEmpty) {
      throw StateError('Invalid refresh response.');
    }

    // Do not resurrect credentials if a user signs out while refresh is in
    // flight. The local logout wins over a late network response.
    if (await _storage.getRefreshToken() != refreshToken) {
      throw StateError('The session changed while it was being refreshed.');
    }
    await _storage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      accessTokenExpiresIn: _intOrNull(data['accessTokenExpiresIn']),
      refreshTokenExpiresIn: _intOrNull(data['refreshTokenExpiresIn']),
    );
    _sessionExpiredNotified = false;
    return newAccessToken;
  }

  Future<void> _expireSessionOnce() async {
    if (_sessionExpiredNotified) return;
    _sessionExpiredNotified = true;
    await _storage.clearTokens();
    onSessionExpired?.call();
    SessionEventBus.notifySessionExpired();
  }

  int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
