import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_mylife/features/family_tree/models/family_v2_models.dart';
import 'package:mobile_mylife/features/family_tree/models/timeline_ownership.dart';

FamilyTimelineEvent event(String type,
        {bool derived = false, String? source}) =>
    FamilyTimelineEvent(
      id: 1,
      eventType: type,
      title: 'Milestone',
      isApproximate: false,
      isDerived: derived,
      sourceType: source,
    );

void main() {
  test('only manually created Timeline event types are editable there', () {
    for (final type in timelineOwnedEventTypes) {
      expect(isTimelineOwnedEvent(event(type)), isTrue, reason: type);
    }
    for (final type in ['BIRTH', 'DEATH', 'ANNIVERSARY', 'PHOTO', 'ALBUM']) {
      expect(isTimelineOwnedEvent(event(type)), isFalse, reason: type);
    }
    expect(isTimelineOwnedEvent(event('MEMORY', derived: true)), isFalse);
  });

  test('derived member and anniversary rows route to their canonical owners',
      () {
    expect(isMemberDerivedEvent(event('BIRTH', derived: true)), isTrue);
    expect(isMemberDerivedEvent(event('DEATH', derived: true)), isTrue);
    expect(isMemberDerivedEvent(event('CUSTOM')), isFalse);
    expect(isAnniversaryTimelineEvent(event('ANNIVERSARY')), isTrue);
    expect(isAnniversaryTimelineEvent(event('CUSTOM', source: 'anniversary')),
        isTrue);
    expect(isAnniversaryTimelineEvent(event('MEMORY')), isFalse);
  });
}
