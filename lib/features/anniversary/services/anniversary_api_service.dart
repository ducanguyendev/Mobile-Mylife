import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/family_anniversary.dart';

final anniversaryApiProvider =
    Provider((ref) => AnniversaryApiService(ref.watch(dioClientProvider)));

class AnniversaryApiService {
  AnniversaryApiService(this._dio);
  final Dio _dio;
  dynamic _data(dynamic value) =>
      value is Map && value.containsKey('data') ? value['data'] : value;
  Future<List<FamilyAnniversary>> list() async {
    final raw = _data((await _dio.get(ApiEndpoints.familyAnniversaries)).data);
    if (raw is! List) throw const FormatException('Invalid anniversary list');
    return raw
        .whereType<Map>()
        .map((v) => FamilyAnniversary.fromJson(Map<String, dynamic>.from(v)))
        .toList();
  }

  Future<FamilyAnniversary> save(FamilyAnniversary value) async {
    final response = value.id == 0
        ? await _dio.post(ApiEndpoints.familyAnniversaries,
            data: value.toJson())
        : await _dio.put(ApiEndpoints.familyAnniversary(value.id),
            data: value.toJson());
    return FamilyAnniversary.fromJson(
        Map<String, dynamic>.from(_data(response.data) as Map));
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiEndpoints.familyAnniversary(id));
  }

  Future<Map<String, dynamic>> nextOccurrence(
          int day, int month, bool leap) async =>
      Map<String, dynamic>.from(_data((await _dio.get(
              ApiEndpoints.familyAnniversaryNextOccurrence,
              queryParameters: {
            'day': day,
            'month': month,
            'isLeapMonth': leap
          }))
          .data) as Map);
  Future<DateTime> convert(int day, int month, int year, bool leap) async {
    final data = Map<String, dynamic>.from(_data((await _dio
            .get(ApiEndpoints.familyAnniversaryLunarToSolar, queryParameters: {
      'day': day,
      'month': month,
      'year': year,
      'isLeapMonth': leap
    }))
        .data) as Map);
    return DateTime.parse(data['solarDate'] as String);
  }
}
