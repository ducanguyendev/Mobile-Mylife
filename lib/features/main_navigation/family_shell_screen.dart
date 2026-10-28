import 'package:flutter/material.dart';
import '../family_map/views/family_map_screen.dart';
import '../family_tree/views/family_tree_screen.dart';

class FamilyShellScreen extends StatefulWidget {
  const FamilyShellScreen({super.key});
  @override
  State<FamilyShellScreen> createState() => _FamilyShellScreenState();
}

class _FamilyShellScreenState extends State<FamilyShellScreen> {
  int _index = 0;
  final _membersKey = GlobalKey<FamilyTreeScreenState>();
  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final labels =
        vi ? ['Cây', 'Thành viên', 'Bản đồ'] : ['Tree', 'Members', 'Map'];
    return Scaffold(
      appBar: AppBar(
        title: Text(vi ? 'Gia đình' : 'Family'),
        actions: [
          if (_index == 1)
            IconButton(
              tooltip: vi ? 'Thêm thành viên' : 'Add member',
              onPressed: () => _membersKey.currentState?.addMember(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
            ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: 0,
                    icon: const Icon(Icons.account_tree_outlined),
                    label: Text(labels[0])),
                ButtonSegment(
                    value: 1,
                    icon: const Icon(Icons.people_outline_rounded),
                    label: Text(labels[1])),
                ButtonSegment(
                    value: 2,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(labels[2])),
              ],
              selected: {_index},
              onSelectionChanged: (selection) =>
                  setState(() => _index = selection.first),
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: [
        const FamilyTreeScreen(
            initialViewMode: 'tree',
            embedded: true,
            showViewSelector: false,
            showAddButton: false),
        FamilyTreeScreen(
            key: _membersKey,
            initialViewMode: 'list',
            embedded: true,
            showViewSelector: false,
            showAddButton: false),
        const FamilyMapScreen(embedded: true),
      ]),
    );
  }
}
