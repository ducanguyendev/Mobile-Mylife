import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/family_map_data.dart';

final familyMapApiProvider =
    Provider((ref) => FamilyMapApiService(ref.watch(dioClientProvider)));

class FamilyMapApiService {
  FamilyMapApiService(this._dio);
  final Dio _dio;
  Future<FamilyMapData> load() async {
    final body = (await _dio.get(ApiEndpoints.familyTreeMap)).data;
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    if (data is! Map) {
      throw const FormatException('Invalid family map response');
    }
    return FamilyMapData.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> updateMemberLocation(
      int memberId, double latitude, double longitude) async {
    await _dio.put('${ApiEndpoints.familyTreeMember(memberId)}/location',
        data: {'latitude': latitude, 'longitude': longitude});
  }
}
