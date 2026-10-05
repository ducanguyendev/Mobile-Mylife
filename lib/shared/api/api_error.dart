import 'package:dio/dio.dart';

/// Extracts the safe, user-facing message from the API's standard error body.
///
/// The server owns error wording.  Status-code fallbacks are only used for
/// transport failures or legacy responses without a message field.
class ApiError {
  const ApiError._();

  static String message(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is! DioException) return fallback;

    final responseData = error.response?.data;
    final serverMessage = _messageFrom(responseData);
    if (serverMessage != null) return serverMessage;

    switch (error.response?.statusCode) {
      case 400:
        return 'The submitted information is invalid.';
      case 401:
        return 'Your session is invalid. Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data.';
      case 500:
      case 502:
      case 503:
        return 'The server is temporarily unavailable. Please try again later.';
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError) {
          return 'Unable to connect to the server. Check your connection and try again.';
        }
        return fallback;
    }
  }

  static String? _messageFrom(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is! Map) return null;

    final direct = data['message'] ?? data['error'] ?? data['title'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();

    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first != null) {
          final message = value.first.toString().trim();
          if (message.isNotEmpty) return message;
        }
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }
}
