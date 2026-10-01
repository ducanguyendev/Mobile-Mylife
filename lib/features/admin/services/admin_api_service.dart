import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/admin_stats_model.dart';
import '../models/admin_user_model.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AdminApiService(dio);
});

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio);

  Future<AdminStatsModel> getStats() async {
    final response = await _dio.get(ApiEndpoints.adminStats);
    return AdminStatsModel.fromJson(response.data);
  }

  Future<List<AdminUserModel>> getUsers({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: search != null ? {'search': search} : null,
    );
    final list = response.data['users'] as List? ?? response.data as List? ?? [];
    return list.map((e) => AdminUserModel.fromJson(e)).toList();
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _dio.put(
      ApiEndpoints.adminUpdateStatus(userId),
      data: {'isActive': isActive},
    );
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    await _dio.put(
      ApiEndpoints.adminUpdateRole(userId),
      data: {'role': newRole},
    );
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete(ApiEndpoints.adminDeleteUser(userId));
  }
}
