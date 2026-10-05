/// Models for the `/api/family-tree` contract.
///
/// Family members are returned as a flat collection. Parent/child links are
/// represented by IDs, so presentation code can build the tree without
/// maintaining a second, locally-mutated copy of the data.
class FamilyMember {
  final int id;
  final String fullName;
  final int generation;
  final String? gender;
  final String? dateOfBirth;
  final String? role;
  final String? address;
  final String? phoneNumber;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? avatarUrl;
  final String? biography;
  final int? fatherId;
  final String? fatherName;
  final int? motherId;
  final String? motherName;
  final int? spouseId;
  final String? spouseName;
  final List<int> childIds;
  final List<String> childNames;
  final List<HorizontalRelation> horizontalRelations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FamilyMember({
    required this.id,
    required this.fullName,
    required this.generation,
    this.gender,
    this.dateOfBirth,
    this.role,
    this.address,
    this.phoneNumber,
    this.facebookUrl,
    this.instagramUrl,
    this.avatarUrl,
    this.biography,
    this.fatherId,
    this.fatherName,
    this.motherId,
    this.motherName,
    this.spouseId,
    this.spouseName,
    this.childIds = const [],
    this.childNames = const [],
    this.horizontalRelations = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// New records use an unsaved ID until the API assigns their integer ID.
  bool get isDraft => id <= 0;

  bool get isFemale {
    final normalized = gender?.trim().toLowerCase();
    return normalized == 'female' || normalized == 'nữ';
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: _asInt(json['id']) ?? 0,
      fullName: _asString(json['fullName']) ?? '',
      generation: _asInt(json['generation']) ?? 1,
      gender: _asString(json['gender']),
      dateOfBirth: _asString(json['dateOfBirth']),
      role: _asString(json['role']),
      address: _asString(json['address']),
      phoneNumber: _asString(json['phoneNumber']),
      facebookUrl: _asString(json['facebookUrl']),
      instagramUrl: _asString(json['instagramUrl']),
      avatarUrl: _asString(json['avatarUrl']),
      biography: _asString(json['biography']),
      fatherId: _asInt(json['fatherId']),
      fatherName: _asString(json['fatherName']),
      motherId: _asInt(json['motherId']),
      motherName: _asString(json['motherName']),
      spouseId: _asInt(json['spouseId']),
      spouseName: _asString(json['spouseName']),
      childIds: _asIntList(json['childIds']),
      childNames: _asStringList(json['childNames']),
      horizontalRelations: _asMapList(json['horizontalRelations'])
          .map(HorizontalRelation.fromJson)
          .toList(growable: false),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  /// DTO accepted by both POST and PUT endpoints. It deliberately omits the
  /// server-managed ID and timestamps.
  Map<String, dynamic> toRequestJson() {
    return {
      'fullName': fullName.trim(),
      'generation': generation,
      'gender': _emptyToNull(gender),
      'dateOfBirth': _emptyToNull(dateOfBirth),
      'role': _emptyToNull(role),
      'address': _emptyToNull(address),
      'phoneNumber': _emptyToNull(phoneNumber),
      'facebookUrl': _emptyToNull(facebookUrl),
      'instagramUrl': _emptyToNull(instagramUrl),
      'avatarUrl': _emptyToNull(avatarUrl),
      'biography': _emptyToNull(biography),
      'fatherId': fatherId,
      'motherId': motherId,
      'spouseId': spouseId,
      'childIds': childIds,
      'horizontalRelations': horizontalRelations
          .map((relation) => relation.toJson())
          .toList(growable: false),
    };
  }
}

class HorizontalRelation {
  final int memberId;
  final String relationType;

  const HorizontalRelation({
    required this.memberId,
    required this.relationType,
  });

  factory HorizontalRelation.fromJson(Map<String, dynamic> json) {
    return HorizontalRelation(
      memberId: _asInt(json['memberId']) ?? 0,
      relationType: _asString(json['relationType']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'relationType': relationType.trim(),
      };
}

class FamilyGeneration {
  final int id;
  final String name;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FamilyGeneration({
    required this.id,
    required this.name,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory FamilyGeneration.fromJson(Map<String, dynamic> json) {
    return FamilyGeneration(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? '',
      title: _asString(json['title']),
      description: _asString(json['description']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _emptyToNull(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _asDateTime(dynamic value) {
  final text = _asString(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<int> _asIntList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_asInt).whereType<int>().toList(growable: false);
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_asString).whereType<String>().toList(growable: false);
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
