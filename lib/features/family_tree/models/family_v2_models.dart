import 'family_member_model.dart';
import '../../anniversary/models/family_anniversary.dart';

class RelationshipPathNode {
  const RelationshipPathNode(
      {required this.memberId, required this.fullName, this.edge});
  final int memberId;
  final String fullName;
  final String? edge;
  factory RelationshipPathNode.fromJson(Map<String, dynamic> json) =>
      RelationshipPathNode(
        memberId: _int(json['memberId']) ?? 0,
        fullName: _string(json['fullName']) ?? '',
        edge: _string(json['edge']),
      );
}

class FamilyRelationshipResult {
  const FamilyRelationshipResult(
      {required this.fromMemberId,
      required this.toMemberId,
      required this.relationshipCode,
      required this.relationshipLabel,
      required this.reverseRelationshipCode,
      required this.reverseRelationshipLabel,
      required this.distance,
      required this.path});
  final int fromMemberId, toMemberId, distance;
  final String relationshipCode,
      relationshipLabel,
      reverseRelationshipCode,
      reverseRelationshipLabel;
  final List<RelationshipPathNode> path;
  factory FamilyRelationshipResult.fromJson(Map<String, dynamic> json) =>
      FamilyRelationshipResult(
        fromMemberId: _int(json['fromMemberId']) ?? 0,
        toMemberId: _int(json['toMemberId']) ?? 0,
        relationshipCode: _string(json['relationshipCode']) ?? 'UNKNOWN',
        relationshipLabel: _string(json['relationshipLabel']) ?? 'Unknown',
        reverseRelationshipCode:
            _string(json['reverseRelationshipCode']) ?? 'UNKNOWN',
        reverseRelationshipLabel:
            _string(json['reverseRelationshipLabel']) ?? 'Unknown',
        distance: _int(json['distance']) ?? -1,
        path: _maps(json['path'])
            .map(RelationshipPathNode.fromJson)
            .toList(growable: false),
      );
}

class FamilyTimelineEvent {
  const FamilyTimelineEvent(
      {required this.id,
      required this.eventType,
      required this.title,
      required this.isApproximate,
      required this.isDerived,
      this.memberId,
      this.memberName,
      this.description,
      this.eventDate,
      this.eventYear,
      this.location,
      this.latitude,
      this.longitude,
      this.relatedMemberId,
      this.sourceType,
      this.sourceId});
  final int id;
  final int? memberId, eventYear, relatedMemberId;
  final int? sourceId;
  final String eventType, title;
  final String? memberName, description, eventDate, location, sourceType;
  final double? latitude, longitude;
  final bool isApproximate, isDerived;
  factory FamilyTimelineEvent.fromJson(Map<String, dynamic> json) =>
      FamilyTimelineEvent(
        id: _int(json['id']) ?? 0,
        memberId: _int(json['memberId']),
        memberName: _string(json['memberName']),
        eventType: _string(json['eventType']) ?? 'CUSTOM',
        title: _string(json['title']) ?? '',
        description: _string(json['description']),
        eventDate: _string(json['eventDate']),
        eventYear: _int(json['eventYear']),
        isApproximate: json['isApproximate'] == true,
        location: _string(json['location']),
        latitude: _double(json['latitude']),
        longitude: _double(json['longitude']),
        relatedMemberId: _int(json['relatedMemberId']),
        sourceType: _string(json['sourceType']),
        sourceId: _int(json['sourceId']),
        isDerived: json['isDerived'] == true,
      );
}

class FamilyMemberProfile {
  const FamilyMemberProfile(
      {required this.member,
      required this.relatives,
      required this.timeline,
      required this.anniversaries,
      required this.libraryMemberLinkAvailable});
  final FamilyMember member;
  final List<FamilyMember> relatives;
  final List<FamilyTimelineEvent> timeline;
  final List<FamilyAnniversary> anniversaries;
  final bool libraryMemberLinkAvailable;
  factory FamilyMemberProfile.fromJson(Map<String, dynamic> json) =>
      FamilyMemberProfile(
        member: FamilyMember.fromJson(_map(json['member'])),
        relatives: _maps(json['relatives'])
            .map(FamilyMember.fromJson)
            .toList(growable: false),
        timeline: _maps(json['timeline'])
            .map(FamilyTimelineEvent.fromJson)
            .toList(growable: false),
        anniversaries: _maps(json['anniversaries'])
            .map(FamilyAnniversary.fromJson)
            .toList(growable: false),
        libraryMemberLinkAvailable: json['libraryMemberLinkAvailable'] == true,
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false)
    : const [];
int? _int(dynamic value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '');
double? _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
String? _string(dynamic value) =>
    value == null || value.toString().trim().isEmpty
        ? null
        : value.toString().trim();
