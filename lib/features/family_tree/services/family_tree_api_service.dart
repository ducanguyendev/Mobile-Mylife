import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/family_member_model.dart';

final familyTreeApiServiceProvider = Provider<FamilyTreeApiService>((ref) {
  return FamilyTreeApiService(ref.watch(dioClientProvider));
});

class FamilyTreeApiService {
  final Dio _dio;

  FamilyTreeApiService(this._dio);

  Future<List<FamilyMember>> getMembers() async {
    final data = await _request(() => _dio.get(ApiEndpoints.familyTree));
    if (data is! List) {
      throw const FamilyTreeApiException(
          'Dữ liệu gia phả trả về không hợp lệ.');
    }

    return data
        .whereType<Map>()
        .map((item) => FamilyMember.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<FamilyGeneration>> getGenerations() async {
    final data =
        await _request(() => _dio.get(ApiEndpoints.familyTreeGenerations));
    if (data is! List) {
      throw const FamilyTreeApiException('Dữ liệu thế hệ trả về không hợp lệ.');
    }

    return data
        .whereType<Map>()
        .map((item) =>
            FamilyGeneration.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<FamilyMember> getMember(int id) async {
    final data = await _request(
      () => _dio.get(ApiEndpoints.familyTreeMember(id)),
    );
    return _memberFromData(data);
  }

  Future<FamilyMember> createMember(FamilyMember member) async {
    final data = await _request(
      () => _dio.post(ApiEndpoints.familyTree, data: member.toRequestJson()),
    );
    return _memberFromData(data);
  }

  Future<FamilyMember> updateMember(FamilyMember member) async {
    if (member.isDraft) {
      throw const FamilyTreeApiException(
        'Không thể cập nhật một thành viên chưa được lưu.',
      );
    }

    final data = await _request(
      () => _dio.put(
        ApiEndpoints.familyTreeMember(member.id),
        data: member.toRequestJson(),
      ),
    );
    return _memberFromData(data);
  }

  Future<void> deleteMember(int id) async {
    await _request(() => _dio.delete(ApiEndpoints.familyTreeMember(id)));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        if (map['success'] == false) {
          throw FamilyTreeApiException(_messageFromBody(map));
        }
        return map.containsKey('data') ? map['data'] : map;
      }
      return body;
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FamilyTreeApiException.fromDio(error),
        stackTrace,
      );
    }
  }

  FamilyMember _memberFromData(dynamic data) {
    if (data is! Map) {
      throw const FamilyTreeApiException(
          'Dữ liệu thành viên trả về không hợp lệ.');
    }
    return FamilyMember.fromJson(Map<String, dynamic>.from(data));
  }
}

class FamilyTreeApiException implements Exception {
  final String message;

  const FamilyTreeApiException(this.message);

  factory FamilyTreeApiException.fromDio(DioException error) {
    final response = error.response;
    final body = response?.data;
    if (body is Map) {
      final message = _messageFromBody(Map<String, dynamic>.from(body));
      if (message.isNotEmpty) return FamilyTreeApiException(message);
    }

    switch (response?.statusCode) {
      case 400:
        return const FamilyTreeApiException('Dữ liệu thành viên không hợp lệ.');
      case 401:
        return const FamilyTreeApiException(
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
      case 403:
        return const FamilyTreeApiException(
          'Bạn không có quyền thực hiện thao tác này.',
        );
      case 404:
        return const FamilyTreeApiException(
            'Không tìm thấy thành viên gia đình.');
      default:
        if ((response?.statusCode ?? 0) >= 500) {
          return const FamilyTreeApiException(
            'Không thể xử lý yêu cầu gia phả. Vui lòng thử lại.',
          );
        }
        return const FamilyTreeApiException(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.',
        );
    }
  }

  @override
  String toString() => message;
}

String _messageFromBody(Map<String, dynamic> body) {
  final directMessage = body['message'] ?? body['title'] ?? body['detail'];
  if (directMessage is String && directMessage.trim().isNotEmpty) {
    return directMessage.trim();
  }

  final errors = body['errors'];
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty && value.first != null) {
        return value.first.toString();
      }
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  return '';
}
