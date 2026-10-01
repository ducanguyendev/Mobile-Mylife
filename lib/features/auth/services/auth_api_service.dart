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
    return response.data;
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String codeOrEmail) async {
    final response = await _dio.post(
      ApiEndpoints.googleAuth,
      data: {
        'code': codeOrEmail,
        'redirectUri': 'http://localhost:5173',
      },
    );
    return response.data;
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
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
    final data = response.data;
    if (data != null && data['user'] != null) {
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    return await getMe();
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
}
