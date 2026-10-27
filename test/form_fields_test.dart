import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_mylife/shared/widgets/forms/mylife_form_fields.dart';
import 'package:mobile_mylife/features/anniversary/models/family_anniversary.dart';

void main() {
  test('form tokens expose matching light and dark field semantics', () {
    const light = MyLifeFormTokens(
      fieldBackground: Color(0xFFFFFFFF),
      fieldBorder: Color(0xFFE6E6E2),
      fieldText: Color(0xFF18181B),
      fieldLabel: Color(0xFF666666),
      fieldPlaceholder: Color(0x9E666666),
      fieldFocusBorder: Color(0xFF71717A),
      fieldFocusRing: Color(0x2471717A),
      fieldError: Color(0xFFEF4444),
      fieldDisabledBackground: Color(0xFFEFEFEC),
    );
    const dark = MyLifeFormTokens(
      fieldBackground: Color(0xFF111111),
      fieldBorder: Color(0xFF3F3F46),
      fieldText: Color(0xFFFFFFFF),
      fieldLabel: Color(0xFFA1A1AA),
      fieldPlaceholder: Color(0x9EA1A1AA),
      fieldFocusBorder: Color(0xFFA1A1AA),
      fieldFocusRing: Color(0x29A1A1AA),
      fieldError: Color(0xFFEF4444),
      fieldDisabledBackground: Color(0xFF18181B),
    );
    expect(light.fieldBackground, isNot(dark.fieldBackground));
    expect(light.fieldError, dark.fieldError);
    expect(light.fieldFocusBorder, isNot(dark.fieldFocusBorder));
  });

  testWidgets(
      'shared field widgets render consistent labels, date, textarea, and validation',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            MyLifeTextField(
                label: 'Event name',
                required: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter a name' : null),
            const SizedBox(height: 12),
            MyLifeSelectField<String>(
                label: 'Event type',
                value: 'family',
                items: const [
                  DropdownMenuItem(value: 'family', child: Text('Event'))
                ],
                onChanged: (_) {}),
            const SizedBox(height: 12),
            MyLifeDateField(
                label: 'Event date',
                value: DateTime(2026, 12, 16),
                onChanged: (_) {}),
            const SizedBox(height: 12),
            const MyLifeTextArea(label: 'Notes', hint: 'Add a note'),
          ]),
        ),
      ),
    ));

    expect(find.text('Event name *'), findsOneWidget);
    expect(find.text('Event type'), findsOneWidget);
    expect(find.text('16/12/2026'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Enter a name'), findsOneWidget);
  });

  test('family event response and write payload keep lunar fields empty', () {
    final familyEvent = FamilyAnniversary.fromJson({
      'id': 8,
      'eventType': 'FAMILY_EVENT',
      'title': 'Family day',
      'relatedMemberId': null,
      'relatedMemberName': null,
      'relatedMemberGeneration': null,
      'relatedMemberRole': null,
      'lunarDay': null,
      'lunarMonth': null,
      'isLeapMonth': false,
      'originalSolarDate': '2026-12-16',
      'lunarYear': null,
      'nextLunarYear': null,
      'nextSolarDate': '2026-12-16',
      'daysUntil': 20,
      'place': null,
      'host': null,
      'notes': null,
    });
    final payload = familyEvent.toJson();
    expect(familyEvent.lunarDay, isNull);
    expect(familyEvent.lunarMonth, isNull);
    expect(familyEvent.nextLunarYear, isNull);
    expect(payload['lunarDay'], isNull);
    expect(payload['lunarMonth'], isNull);
    expect(payload['lunarYear'], isNull);
    expect(payload['isLeapMonth'], isFalse);
    expect(payload['originalSolarDate'], '2026-12-16');
  });
}
