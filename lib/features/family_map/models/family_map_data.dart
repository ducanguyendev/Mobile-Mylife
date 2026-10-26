class FamilyMapMember {
  const FamilyMapMember(
      {required this.id, required this.fullName, required this.generation});
  final int id;
  final String fullName;
  final int generation;
  factory FamilyMapMember.fromJson(Map<String, dynamic> j) => FamilyMapMember(
      id: j['id'] as int,
      fullName: j['fullName'] as String,
      generation: j['generation'] as int);
}

class FamilyMapLocation {
  const FamilyMapLocation(
      {required this.key,
      required this.displayName,
      required this.latitude,
      required this.longitude,
      required this.memberCount,
      required this.members});
  final String key, displayName;
  final double latitude, longitude;
  final int memberCount;
  final List<FamilyMapMember> members;
  factory FamilyMapLocation.fromJson(Map<String, dynamic> j) =>
      FamilyMapLocation(
          key: j['key'] as String,
          displayName: j['displayName'] as String,
          latitude: (j['latitude'] as num).toDouble(),
          longitude: (j['longitude'] as num).toDouble(),
          memberCount: j['memberCount'] as int,
          members: (j['members'] as List? ?? const [])
              .whereType<Map>()
              .map(
                  (v) => FamilyMapMember.fromJson(Map<String, dynamic>.from(v)))
              .toList());
}

class FamilyMapData {
  const FamilyMapData(
      {required this.totalMembers,
      required this.locatedMembers,
      required this.unlocatedMembers,
      required this.pendingGeocodingMembers,
      required this.noAddressMembers,
      required this.failedGeocodingMembers,
      required this.locations,
      this.members = const []});
  final int totalMembers,
      locatedMembers,
      unlocatedMembers,
      pendingGeocodingMembers,
      noAddressMembers,
      failedGeocodingMembers;
  final List<FamilyMapLocation> locations;
  final List<FamilyMapMemberLocation> members;
  factory FamilyMapData.fromJson(Map<String, dynamic> j) => FamilyMapData(
      totalMembers: j['totalMembers'] as int,
      locatedMembers: j['locatedMembers'] as int,
      unlocatedMembers: j['unlocatedMembers'] as int,
      pendingGeocodingMembers: j['pendingGeocodingMembers'] as int,
      noAddressMembers: j['noAddressMembers'] as int,
      failedGeocodingMembers: j['failedGeocodingMembers'] as int,
      members: (j['members'] as List? ?? const [])
          .whereType<Map>()
          .map((v) =>
              FamilyMapMemberLocation.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
      locations: (j['locations'] as List? ?? const [])
          .whereType<Map>()
          .map((v) => FamilyMapLocation.fromJson(Map<String, dynamic>.from(v)))
          .toList());
}

class FamilyMapMemberLocation {
  const FamilyMapMemberLocation({
    required this.id,
    required this.fullName,
    required this.generation,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
    this.locationDisplayName,
    this.locationSource,
  });

  final int id;
  final String fullName;
  final int generation;
  final String status;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? locationDisplayName;
  final String? locationSource;

  factory FamilyMapMemberLocation.fromJson(Map<String, dynamic> json) =>
      FamilyMapMemberLocation(
        id: json['id'] as int,
        fullName: json['fullName'] as String,
        generation: json['generation'] as int,
        status: json['status'] as String? ?? 'UNAVAILABLE',
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        locationDisplayName: json['locationDisplayName'] as String?,
        locationSource: json['locationSource'] as String?,
      );
}
