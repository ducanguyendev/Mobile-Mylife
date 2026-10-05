import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/auth_requests.dart';
import '../models/user_model.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthApiService(dio);
});

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return _asMap(response.data);
  }

  /// Mobile Google login accepts only an ID token issued by Google Sign-In.
  /// An email address is never treated as a credential.
  Future<Map<String, dynamic>> loginWithGoogleIdToken(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.googleAuth,
      data: {
        'idToken': idToken,
      },
    );
    return _asMap(response.data);
  }

  Future<void> logout(String? refreshToken) async {
    await _dio.post(
      ApiEndpoints.logout,
      data: refreshToken == null || refreshToken.isEmpty
          ? null
          : {'refreshToken': refreshToken},
    );
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(_asMap(response.data));
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.updateProfile,
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
      },
    );
    final data = _asMap(response.data);
    final rawUser = data['user'];
    if (rawUser is Map<String, dynamic>) {
      return UserModel.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return UserModel.fromJson(
        rawUser.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return getMe();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    throw const FormatException('The server returned an invalid response.');
  }
}
