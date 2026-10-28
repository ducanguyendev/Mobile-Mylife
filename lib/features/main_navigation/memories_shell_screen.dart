import 'package:flutter/material.dart';
import '../anniversary/views/anniversary_screen.dart';
import '../library/views/library_screen.dart';
import '../my_life/views/family_timeline_screen.dart';

class MemoriesShellScreen extends StatefulWidget {
  const MemoriesShellScreen(
      {super.key,
      this.initialIndex = 0,
      this.initialEventId,
      this.initialAnniversaryId});
  final int initialIndex;
  final int? initialEventId;
  final int? initialAnniversaryId;
  @override
  State<MemoriesShellScreen> createState() => _MemoriesShellScreenState();
}

class _MemoriesShellScreenState extends State<MemoriesShellScreen> {
  late int _index = widget.initialIndex.clamp(0, 2);
  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final labels = vi
        ? ['Dòng thời gian', 'Lịch', 'Thư viện']
        : ['Timeline', 'Calendar', 'Library'];
    return Scaffold(
      body: Column(children: [
        SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                      value: 0,
                      icon: const Icon(Icons.timeline_rounded),
                      label: Text(labels[0])),
                  ButtonSegment(
                      value: 1,
                      icon: const Icon(Icons.event_note_rounded),
                      label: Text(labels[1])),
                  ButtonSegment(
                      value: 2,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(labels[2])),
                ],
                selected: {_index},
                onSelectionChanged: (selection) =>
                    setState(() => _index = selection.first),
              ),
            )),
        Expanded(
            child: IndexedStack(index: _index, children: [
          FamilyTimelineScreen(initialEventId: widget.initialEventId),
          AnniversaryScreen(initialEventId: widget.initialAnniversaryId),
          const LibraryScreen(),
        ])),
      ]),
    );
  }
}
