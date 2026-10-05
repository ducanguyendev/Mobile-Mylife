import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_mylife/features/family_tree/models/family_member_model.dart';

void main() {
  group('FamilyMember', () {
    test('parses the backend DTO with null-safe integer relationships', () {
      final member = FamilyMember.fromJson({
        'id': 12,
        'fullName': 'Nguyễn Văn An',
        'generation': 3,
        'gender': 'male',
        'dateOfBirth': '1990-02-03',
        'role': 'Con trưởng',
        'fatherId': '4',
        'motherId': 5,
        'spouseId': null,
        'childIds': [8, '9', null],
        'childNames': ['Bé A', 'Bé B'],
        'horizontalRelations': [
          {'memberId': '10', 'relationType': 'anh em'},
        ],
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      });

      expect(member.id, 12);
      expect(member.fullName, 'Nguyễn Văn An');
      expect(member.fatherId, 4);
      expect(member.motherId, 5);
      expect(member.childIds, [8, 9]);
      expect(member.horizontalRelations.single.memberId, 10);
      expect(member.horizontalRelations.single.relationType, 'anh em');
      expect(member.createdAt, DateTime.parse('2026-01-01T00:00:00Z'));
    });

    test('serializes the create/update request without server-managed fields',
        () {
      const member = FamilyMember(
        id: 12,
        fullName: ' Nguyễn Văn An ',
        generation: 3,
        role: ' ',
        childIds: [8],
        horizontalRelations: [
          HorizontalRelation(memberId: 10, relationType: ' anh em '),
        ],
      );

      final request = member.toRequestJson();

      expect(request['fullName'], 'Nguyễn Văn An');
      expect(request['role'], isNull);
      expect(request['childIds'], [8]);
      expect(request['horizontalRelations'], [
        {'memberId': 10, 'relationType': 'anh em'},
      ]);
      expect(request.containsKey('id'), isFalse);
      expect(request.containsKey('createdAt'), isFalse);
    });
  });
}
