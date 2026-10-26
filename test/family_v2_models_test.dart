import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_mylife/features/family_tree/models/family_v2_models.dart';

void main() {
  test('relationship result parses the backend path and neutral reverse label',
      () {
    final result = FamilyRelationshipResult.fromJson({
      'fromMemberId': 1,
      'toMemberId': 2,
      'relationshipCode': 'FATHER',
      'relationshipLabel': 'Father',
      'reverseRelationshipCode': 'SON',
      'reverseRelationshipLabel': 'Son',
      'distance': 1,
      'path': [
        {'memberId': 1, 'fullName': 'Child'},
        {'memberId': 2, 'fullName': 'Parent', 'edge': 'PARENT'},
      ],
    });

    expect(result.relationshipCode, 'FATHER');
    expect(result.reverseRelationshipCode, 'SON');
    expect(result.path.last.edge, 'PARENT');
  });

  test('timeline events parse optional dates and coordinates without crashing',
      () {
    final event = FamilyTimelineEvent.fromJson({
      'id': 5,
      'eventType': 'ADDRESS_CHANGE',
      'title': 'Moved home',
      'eventYear': 1975,
      'isApproximate': true,
      'latitude': '10.77',
      'longitude': 106.69,
      'isDerived': false,
    });

    expect(event.eventDate, isNull);
    expect(event.eventYear, 1975);
    expect(event.isApproximate, isTrue);
    expect(event.latitude, 10.77);
  });

  test('member profile safely parses absent relationship and timeline arrays',
      () {
    final profile = FamilyMemberProfile.fromJson({
      'member': {'id': 10, 'fullName': 'Member', 'generation': 2},
      'relatives': null,
      'timeline': null,
      'anniversaries': [],
      'libraryMemberLinkAvailable': false,
    });

    expect(profile.member.id, 10);
    expect(profile.relatives, isEmpty);
    expect(profile.timeline, isEmpty);
    expect(profile.libraryMemberLinkAvailable, isFalse);
  });
}
