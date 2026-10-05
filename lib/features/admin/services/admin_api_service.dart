import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../../auth/models/user_model.dart';
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
    final trimmedSearch = search?.trim();
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: trimmedSearch == null || trimmedSearch.isEmpty
          ? null
          : {'search': trimmedSearch},
    );
    final data = response.data;
    final list = data is List
        ? data
        : data is Map && data['users'] is List
            ? data['users'] as List
            : null;
    if (list == null) {
      throw const FormatException('The server returned an invalid user list.');
    }
    return list
        .whereType<Map>()
        .map(
          (value) => AdminUserModel.fromJson(
            value.map((key, item) => MapEntry(key.toString(), item)),
          ),
        )
        .toList();
  }

  Future<void> toggleUserStatus(int userId, bool isActive) async {
    await _dio.put(
      ApiEndpoints.adminUpdateStatus(userId),
      data: {'isActive': isActive},
    );
  }

  Future<void> changeUserRole(int userId, String newRole) async {
    final normalizedRole = UserModel.normalizeRole(newRole);
    if (normalizedRole != newRole.trim().toUpperCase()) {
      throw ArgumentError.value(newRole, 'newRole', 'Role must be ADMIN or USER.');
    }
    await _dio.put(
      ApiEndpoints.adminUpdateRole(userId),
      data: {'role': normalizedRole},
    );
  }

  Future<void> deleteUser(int userId) async {
    await _dio.delete(ApiEndpoints.adminDeleteUser(userId));
  }
}
