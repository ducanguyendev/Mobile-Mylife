class FamilyAnniversary {
  const FamilyAnniversary(
      {required this.id,
      required this.eventType,
      required this.title,
      this.relatedMemberId,
      this.relatedMemberName,
      this.relatedMemberGeneration,
      this.relatedMemberRole,
      required this.lunarDay,
      required this.lunarMonth,
      required this.isLeapMonth,
      this.originalSolarDate,
      this.lunarYear,
      required this.nextLunarYear,
      required this.nextSolarDate,
      required this.daysUntil,
      this.place,
      this.host,
      this.notes});
  final int id;
  final String eventType;
  final String title;
  final int? relatedMemberId;
  final String? relatedMemberName;
  final int? relatedMemberGeneration;
  final String? relatedMemberRole;
  final int lunarDay;
  final int lunarMonth;
  final bool isLeapMonth;
  final DateTime? originalSolarDate;
  final int? lunarYear;
  final int nextLunarYear;
  final DateTime nextSolarDate;
  final int daysUntil;
  final String? place;
  final String? host;
  final String? notes;
  factory FamilyAnniversary.fromJson(Map<String, dynamic> j) =>
      FamilyAnniversary(
          id: j['id'] as int,
          eventType: j['eventType'] as String,
          title: j['title'] as String,
          relatedMemberId: j['relatedMemberId'] as int?,
          relatedMemberName: j['relatedMemberName'] as String?,
          relatedMemberGeneration: j['relatedMemberGeneration'] as int?,
          relatedMemberRole: j['relatedMemberRole'] as String?,
          lunarDay: j['lunarDay'] as int,
          lunarMonth: j['lunarMonth'] as int,
          isLeapMonth: j['isLeapMonth'] as bool? ?? false,
          originalSolarDate:
              DateTime.tryParse(j['originalSolarDate'] as String? ?? ''),
          lunarYear: j['lunarYear'] as int?,
          nextLunarYear: j['nextLunarYear'] as int,
          nextSolarDate: DateTime.parse(j['nextSolarDate'] as String),
          daysUntil: j['daysUntil'] as int,
          place: j['place'] as String?,
          host: j['host'] as String?,
          notes: j['notes'] as String?);
  Map<String, Object?> toJson() => {
        'eventType': eventType,
        'title': title,
        'relatedMemberId': relatedMemberId,
        'lunarDay': lunarDay,
        'lunarMonth': lunarMonth,
        'isLeapMonth': isLeapMonth,
        'originalSolarDate':
            originalSolarDate == null ? null : _date(originalSolarDate!),
        'lunarYear': lunarYear,
        'place': _clean(place),
        'host': _clean(host),
        'notes': _clean(notes)
      };
  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String? _clean(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();
}
