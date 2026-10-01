import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';

final avatarApiServiceProvider = Provider<AvatarApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AvatarApiService(dio);
});

class AvatarApiService {
  final Dio _dio;

  AvatarApiService(this._dio);

  Future<String?> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    String subType = 'jpeg';
    if (ext == 'png') {
      subType = 'png';
    } else if (ext == 'webp') {
      subType = 'webp';
    } else if (ext == 'gif') {
      subType = 'gif';
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType('image', subType),
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.uploadAvatar,
      data: formData,
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['avatarUrl'] as String?;
    }
    return null;
  }

  Future<bool> deleteAvatar() async {
    final response = await _dio.delete(ApiEndpoints.deleteAvatar);
    return response.statusCode == 200;
  }
}
