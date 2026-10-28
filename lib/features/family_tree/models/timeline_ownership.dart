import 'family_v2_models.dart';

const timelineOwnedEventTypes = <String>{
  'CUSTOM',
  'MEMORY',
  'ADDRESS_CHANGE',
  'MARRIAGE',
};

bool isTimelineOwnedEvent(FamilyTimelineEvent event) =>
    !event.isDerived && timelineOwnedEventTypes.contains(event.eventType);

bool isMemberDerivedEvent(FamilyTimelineEvent event) =>
    event.eventType == 'BIRTH' || event.eventType == 'DEATH';

bool isAnniversaryTimelineEvent(FamilyTimelineEvent event) =>
    event.eventType == 'ANNIVERSARY' ||
    event.sourceType?.toUpperCase() == 'ANNIVERSARY';
