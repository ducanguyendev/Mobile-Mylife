class FamilyMember {
  final String id;
  final String name;
  final String? title;
  final String? parentId;
  final String? imageUrl;
  final String? birthDate;
  final String? deathDate;
  
  List<FamilyMember> children;

  FamilyMember({
    required this.id,
    required this.name,
    this.title,
    this.parentId,
    this.imageUrl,
    this.birthDate,
    this.deathDate,
    this.children = const [],
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String?,
      parentId: json['parentId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      birthDate: json['birthDate'] as String?,
      deathDate: json['deathDate'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'parentId': parentId,
      'imageUrl': imageUrl,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
