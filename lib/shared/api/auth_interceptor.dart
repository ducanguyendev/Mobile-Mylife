import 'package:dio/dio.dart';
import '../services/session_events.dart';
import '../services/token_storage_service.dart';
import 'api_endpoints.dart';

typedef SessionExpiredCallback = void Function();

class AuthInterceptor extends Interceptor {
  final TokenStorageService _storage;
  final Dio _dio;
  final SessionExpiredCallback? onSessionExpired;
  bool _isRefreshing = false;
  final List<void Function(String token)> _retryQueue = [];

  AuthInterceptor(this._storage, this._dio, {this.onSessionExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      final accessToken = await _storage.getAccessToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        if (!_isRefreshing) {
          _isRefreshing = true;

          try {
            final baseUrl = await _storage.getBaseUrl();
            final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

            final res = await refreshDio.post(
              ApiEndpoints.refreshToken,
              data: {
                'accessToken': accessToken,
                'refreshToken': refreshToken,
              },
            );

            if (res.statusCode == 200 && res.data != null) {
              final newAccessToken = res.data['accessToken'] as String;
              final newRefreshToken = res.data['refreshToken'] as String;

              await _storage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Xử lý lại hàng đợi các request bị hoãn
              for (var callback in _retryQueue) {
                callback(newAccessToken);
              }
              _retryQueue.clear();
              _isRefreshing = false;

              // Gửi lại request vừa bị lỗi 401 ban đầu
              err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            } else {
              throw Exception('Refresh token failed');
            }
          } catch (e) {
            _isRefreshing = false;
            _retryQueue.clear();
            await _storage.clearTokens();
            onSessionExpired?.call();
            SessionEventBus.notifySessionExpired();
            return handler.reject(err);
          }
        } else {
          // Nếu đang có tiến trình refresh token, cho request này vào queue chờ
          _retryQueue.add((newToken) async {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch(err.requestOptions);
            handler.resolve(retryResponse);
          });
          return;
        }
      } else {
        // Có lỗi 401 và không có refresh token -> phiên làm việc đã kết thúc
        await _storage.clearTokens();
        onSessionExpired?.call();
        SessionEventBus.notifySessionExpired();
      }
    }

    return handler.next(err);
  }
}
