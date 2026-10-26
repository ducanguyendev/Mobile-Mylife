import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_endpoints.dart';
import '../../../shared/api/dio_client.dart';
import '../models/family_v2_models.dart';

final familyV2ApiServiceProvider = Provider<FamilyV2ApiService>(
    (ref) => FamilyV2ApiService(ref.watch(dioClientProvider)));

class FamilyV2ApiService {
  FamilyV2ApiService(this._dio);
  final Dio _dio;

  Future<FamilyRelationshipResult> getRelationship(
      int fromMemberId, int toMemberId) async {
    final raw = _data((await _dio.get(ApiEndpoints.familyRelationship,
            queryParameters: {
          'fromMemberId': fromMemberId,
          'toMemberId': toMemberId
        }))
        .data);
    if (raw is! Map) {
      throw const FormatException('Invalid relationship response');
    }
    return FamilyRelationshipResult.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<FamilyMemberProfile> getMemberProfile(int memberId) async {
    final raw = _data(
        (await _dio.get(ApiEndpoints.familyMemberProfile(memberId))).data);
    if (raw is! Map) {
      throw const FormatException('Invalid member profile response');
    }
    return FamilyMemberProfile.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<FamilyTimelineEvent>> getTimeline({int? memberId}) async {
    final path = memberId == null
        ? ApiEndpoints.familyTimeline
        : ApiEndpoints.familyMemberTimeline(memberId);
    final raw = _data((await _dio.get(path)).data);
    if (raw is! List) {
      throw const FormatException('Invalid family timeline response');
    }
    return raw
        .whereType<Map>()
        .map((item) =>
            FamilyTimelineEvent.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<FamilyTimelineEvent> saveTimelineEvent(Map<String, dynamic> payload,
      {int? id}) async {
    final response = id == null
        ? await _dio.post(ApiEndpoints.familyTimeline, data: payload)
        : await _dio.put(ApiEndpoints.familyTimelineEvent(id), data: payload);
    final raw = _data(response.data);
    if (raw is! Map) {
      throw const FormatException('Invalid saved timeline event');
    }
    return FamilyTimelineEvent.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> deleteTimelineEvent(int id) async {
    await _dio.delete(ApiEndpoints.familyTimelineEvent(id));
  }

  dynamic _data(dynamic value) =>
      value is Map && value.containsKey('data') ? value['data'] : value;
}
