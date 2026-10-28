import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/mylife_design_tokens.dart';
import '../../family_tree/models/family_v2_models.dart';
import '../../family_tree/models/timeline_ownership.dart';
import '../../family_tree/providers/family_tree_provider.dart';
import '../../family_tree/services/family_v2_api_service.dart';
import '../../family_tree/views/family_member_profile_route.dart';
import '../../main_navigation/memories_shell_screen.dart';

enum _TimelineFilter { all, birth, marriage, family, location, memory, other }

class FamilyTimelineScreen extends ConsumerStatefulWidget {
  const FamilyTimelineScreen({super.key, this.initialEventId});
  final int? initialEventId;
  @override
  ConsumerState<FamilyTimelineScreen> createState() =>
      _FamilyTimelineScreenState();
}

class _FamilyTimelineScreenState extends ConsumerState<FamilyTimelineScreen> {
  late Future<List<FamilyTimelineEvent>> _events;
  _TimelineFilter _filter = _TimelineFilter.all;
  @override
  void initState() {
    super.initState();
    _events = _load();
  }

  Future<List<FamilyTimelineEvent>> _load() async {
    final notifier = ref.read(familyTreeProvider.notifier);
    if (ref.read(familyTreeProvider).members.isEmpty) await notifier.load();
    final events = await ref.read(familyV2ApiServiceProvider).getTimeline();
    final linked =
        events.where((event) => event.id == widget.initialEventId).firstOrNull;
    if (linked != null) {
      _filter = switch (linked.eventType) {
        'BIRTH' || 'DEATH' => _TimelineFilter.birth,
        'MARRIAGE' => _TimelineFilter.marriage,
        'CUSTOM' || 'CHILD_BIRTH' => _TimelineFilter.family,
        'ADDRESS_CHANGE' => _TimelineFilter.location,
        'MEMORY' || 'ANNIVERSARY' => _TimelineFilter.memory,
        _ => _TimelineFilter.other,
      };
    }
    return events;
  }

  bool _matches(String type) {
    switch (_filter) {
      case _TimelineFilter.all:
        return true;
      case _TimelineFilter.birth:
        return type == 'BIRTH' || type == 'DEATH';
      case _TimelineFilter.marriage:
        return type == 'MARRIAGE';
      case _TimelineFilter.family:
        return type == 'CUSTOM' || type == 'CHILD_BIRTH';
      case _TimelineFilter.location:
        return type == 'ADDRESS_CHANGE';
      case _TimelineFilter.memory:
        return type == 'MEMORY' || type == 'ANNIVERSARY';
      case _TimelineFilter.other:
        return !const [
          'BIRTH',
          'DEATH',
          'MARRIAGE',
          'CUSTOM',
          'CHILD_BIRTH',
          'ADDRESS_CHANGE',
          'MEMORY',
          'ANNIVERSARY'
        ].contains(type);
    }
  }

  bool _owns(FamilyTimelineEvent event) => isTimelineOwnedEvent(event);

  String? get _createType => switch (_filter) {
        _TimelineFilter.birth || _TimelineFilter.other => null,
        _TimelineFilter.marriage => 'MARRIAGE',
        _TimelineFilter.location => 'ADDRESS_CHANGE',
        _TimelineFilter.memory => 'MEMORY',
        _ => 'CUSTOM',
      };
  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    return Scaffold(
      floatingActionButton: _createType == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(vi: vi),
              icon: const Icon(Icons.add_rounded),
              label: Text(vi ? 'Thêm sự kiện' : 'Add event')),
      body: FutureBuilder<List<FamilyTimelineEvent>>(
        future: _events,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <FamilyTimelineEvent>[];
          final filtered =
              data.where((event) => _matches(event.eventType)).toList();
          final groups = _group(filtered);
          return CustomScrollView(slivers: [
            SliverAppBar.large(
                pinned: true,
                title: Text(vi ? 'Dòng thời gian' : 'Family timeline'),
                actions: [
                  IconButton(
                      tooltip: vi ? 'Tải lại' : 'Refresh',
                      onPressed: () => setState(() => _events = _load()),
                      icon: const Icon(Icons.refresh_rounded)),
                  const SizedBox(width: 8),
                ]),
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final filter in _TimelineFilter.values)
                        _filterChip(filter, vi),
                    ]))),
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              SliverFillRemaining(
                  child: _EmptyTimeline(
                      icon: Icons.cloud_off_outlined,
                      title: vi
                          ? 'Không tải được dòng thời gian'
                          : 'Could not load timeline',
                      detail: vi
                          ? 'Kiểm tra kết nối rồi thử lại.'
                          : 'Check your connection and try again.',
                      action: vi ? 'Thử lại' : 'Retry',
                      onAction: () => setState(() => _events = _load())))
            else if (filtered.isEmpty)
              SliverFillRemaining(
                  child: _EmptyTimeline(
                      icon: Icons.auto_stories_outlined,
                      title:
                          vi ? 'Chưa có sự kiện ở đây' : 'No events here yet',
                      detail: vi
                          ? 'Những dấu mốc của gia đình sẽ được lưu tại đây.'
                          : 'Family milestones will appear here.',
                      action: null,
                      onAction: null))
            else
              SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    for (final entry in groups.entries) ...[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                          child: Text(
                              entry.key?.toString() ??
                                  (vi ? 'Chưa rõ năm' : 'Unknown year'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: MyLifeDesign.teal))),
                      for (final event in entry.value)
                        _TimelineEventTile(
                            event: event,
                            vi: vi,
                            canManage: _owns(event),
                            highlighted: event.id == widget.initialEventId,
                            onOpen: () => _openOwner(event, vi),
                            onEdit: () => _edit(event: event, vi: vi),
                            onDelete: () => _delete(event, vi)),
                    ],
                  ]))),
          ]);
        },
      ),
    );
  }

  Widget _filterChip(_TimelineFilter filter, bool vi) {
    final labels = {
      _TimelineFilter.all: vi ? 'Tất cả' : 'All',
      _TimelineFilter.birth: vi ? 'Sinh & mất' : 'Birth & death',
      _TimelineFilter.marriage: vi ? 'Hôn nhân' : 'Marriage',
      _TimelineFilter.family: vi ? 'Gia đình' : 'Family',
      _TimelineFilter.location: vi ? 'Địa điểm' : 'Location',
      _TimelineFilter.memory: vi ? 'Ký ức' : 'Memory',
      _TimelineFilter.other: vi ? 'Khác' : 'Other'
    };
    final selected = _filter == filter;
    return AnimatedContainer(
        duration: MyLifeDesign.fast,
        decoration: BoxDecoration(
            color: selected
                ? MyLifeDesign.teal.withValues(alpha: .14)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color: selected ? MyLifeDesign.teal : Colors.transparent)),
        child: InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filter = filter);
            },
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Text(labels[filter]!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? MyLifeDesign.teal : null)))));
  }

  Map<int?, List<FamilyTimelineEvent>> _group(
      List<FamilyTimelineEvent> events) {
    final sorted = [...events]..sort((a, b) => _sort(a).compareTo(_sort(b)));
    final result = <int?, List<FamilyTimelineEvent>>{};
    for (final event in sorted) {
      final year = event.eventDate != null
          ? int.tryParse(event.eventDate!.substring(0, 4))
          : event.eventYear;
      (result[year] ??= []).add(event);
    }
    return Map.fromEntries(result.entries.toList()
      ..sort((a, b) => a.key == null
          ? 1
          : b.key == null
              ? -1
              : a.key!.compareTo(b.key!)));
  }

  int _sort(FamilyTimelineEvent e) => e.eventDate != null
      ? DateTime.tryParse(e.eventDate!)?.millisecondsSinceEpoch ?? 0
      : e.eventYear == null
          ? 1 << 62
          : DateTime(e.eventYear!, 1, 1).millisecondsSinceEpoch;
  Future<void> _edit({FamilyTimelineEvent? event, required bool vi}) async {
    if (event != null && !_owns(event)) {
      return;
    }
    final api = ref.read(familyV2ApiServiceProvider);
    final members = ref.read(familyTreeProvider).members;
    final type = event?.eventType ?? _createType!;
    final title = TextEditingController(text: event?.title ?? '');
    final description = TextEditingController(text: event?.description ?? '');
    final date =
        TextEditingController(text: event?.eventDate?.substring(0, 10) ?? '');
    final year =
        TextEditingController(text: event?.eventYear?.toString() ?? '');
    final location = TextEditingController(text: event?.location ?? '');
    final approx = ValueNotifier<bool>(event?.isApproximate ?? false);
    int? memberId = event?.memberId;
    final formKey = GlobalKey<FormState>();
    final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(MyLifeDesign.sheetRadius))),
        builder: (context) => StatefulBuilder(
            builder: (context, setSheet) => Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Center(
                              child: Container(
                                  width: 38,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                      borderRadius: BorderRadius.circular(9)))),
                          const SizedBox(height: 20),
                          Text(
                              event == null
                                  ? (vi ? 'Một dấu mốc mới' : 'A new milestone')
                                  : (vi
                                      ? 'Chỉnh sửa dấu mốc'
                                      : 'Edit milestone'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<int?>(
                              initialValue: memberId,
                              decoration: InputDecoration(
                                  labelText:
                                      vi ? 'Thành viên' : 'Family member'),
                              items: [
                                DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(
                                        vi ? 'Cả gia đình' : 'Whole family')),
                                ...members.map((m) => DropdownMenuItem<int?>(
                                    value: m.id, child: Text(m.fullName)))
                              ],
                              onChanged: (v) => setSheet(() => memberId = v)),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: title,
                              decoration: InputDecoration(
                                  labelText: vi ? 'Tiêu đề' : 'Title'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? (vi ? 'Nhập tiêu đề' : 'Enter a title')
                                  : null),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: date,
                              decoration: InputDecoration(
                                  labelText: vi
                                      ? 'Ngày (YYYY-MM-DD)'
                                      : 'Date (YYYY-MM-DD)',
                                  hintText: '2001-05-12'),
                              keyboardType: TextInputType.datetime),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: year,
                              decoration: InputDecoration(
                                  labelText: vi
                                      ? 'Năm (nếu không rõ ngày)'
                                      : 'Year (if date is unknown)'),
                              keyboardType: TextInputType.number),
                          ValueListenableBuilder<bool>(
                              valueListenable: approx,
                              builder: (context, value, _) => SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(vi
                                      ? 'Ngày ước lượng'
                                      : 'Approximate date'),
                                  value: value,
                                  onChanged: (v) => approx.value = v)),
                          TextFormField(
                              controller: location,
                              decoration: InputDecoration(
                                  labelText: vi ? 'Địa điểm' : 'Location')),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: description,
                              minLines: 2,
                              maxLines: 4,
                              decoration: InputDecoration(
                                  labelText: vi ? 'Ghi chú' : 'Description')),
                          const SizedBox(height: 20),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final d = date.text.trim();
                                    final y = int.tryParse(year.text.trim());
                                    final parsed = DateTime.tryParse(d);
                                    if (d.isNotEmpty && parsed == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(vi
                                                  ? 'Ngày cần đúng định dạng YYYY-MM-DD'
                                                  : 'Use YYYY-MM-DD for the date')));
                                      return;
                                    }
                                    if (parsed == null && y == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(vi
                                                  ? 'Nhập ngày hoặc năm sự kiện'
                                                  : 'Enter an event date or year')));
                                      return;
                                    }
                                    try {
                                      await api.saveTimelineEvent({
                                        'memberId': memberId,
                                        'eventType': type,
                                        'title': title.text.trim(),
                                        'description':
                                            description.text.trim().isEmpty
                                                ? null
                                                : description.text.trim(),
                                        'eventDate': parsed == null ? null : d,
                                        'eventYear': parsed?.year ?? y,
                                        'isApproximate': approx.value,
                                        'location': location.text.trim().isEmpty
                                            ? null
                                            : location.text.trim(),
                                        'latitude': event?.latitude,
                                        'longitude': event?.longitude,
                                        'relatedMemberId':
                                            event?.relatedMemberId
                                      }, id: event?.id);
                                      if (context.mounted) {
                                        Navigator.pop(context, true);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(e.toString())));
                                      }
                                    }
                                  },
                                  child: Text(
                                      vi ? 'Lưu dấu mốc' : 'Save milestone'))),
                        ]))))));
    title.dispose();
    description.dispose();
    date.dispose();
    year.dispose();
    location.dispose();
    approx.dispose();
    if (saved == true && mounted) setState(() => _events = _load());
  }

  Future<void> _delete(FamilyTimelineEvent event, bool vi) async {
    if (!_owns(event)) {
      return;
    }
    final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(vi ? 'Xóa dấu mốc?' : 'Delete milestone?'),
                content: Text(event.title),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(vi ? 'Hủy' : 'Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(vi ? 'Xóa' : 'Delete'))
                ]));
    if (yes == true) {
      try {
        await ref
            .read(familyV2ApiServiceProvider)
            .deleteTimelineEvent(event.id);
        if (mounted) setState(() => _events = _load());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _openOwner(FamilyTimelineEvent event, bool vi) {
    if (isMemberDerivedEvent(event) && event.memberId != null) {
      final member = ref
          .read(familyTreeProvider)
          .members
          .where((item) => item.id == event.memberId)
          .firstOrNull;
      if (member != null) {
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => FamilyMemberProfileRoute(member: member),
        ));
      }
    } else if (isAnniversaryTimelineEvent(event)) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MemoriesShellScreen(
          initialIndex: 1,
          initialAnniversaryId: event.sourceId,
        ),
      ));
    }
  }
}

class _TimelineEventTile extends StatelessWidget {
  const _TimelineEventTile(
      {required this.event,
      required this.vi,
      required this.canManage,
      required this.highlighted,
      required this.onOpen,
      required this.onEdit,
      required this.onDelete});
  final FamilyTimelineEvent event;
  final bool vi;
  final bool canManage;
  final bool highlighted;
  final VoidCallback onOpen;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final date = event.eventDate != null
        ? event.eventDate!.substring(0, 10)
        : event.eventYear?.toString() ?? (vi ? 'Chưa rõ ngày' : 'Unknown date');
    final memberEvent = isMemberDerivedEvent(event);
    final anniversaryEvent = isAnniversaryTimelineEvent(event);
    return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 54,
              child: Text(date,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: MyLifeDesign.teal, fontWeight: FontWeight.w800))),
          Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                  color: MyLifeDesign.teal, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
              child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: highlighted
                          ? Border.all(color: MyLifeDesign.teal, width: 1.5)
                          : null,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(event.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800))),
                            if (canManage)
                              PopupMenuButton<String>(
                                  itemBuilder: (_) => [
                                        PopupMenuItem(
                                            value: 'edit',
                                            child: Text(vi ? 'Sửa' : 'Edit')),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text(vi ? 'Xóa' : 'Delete'))
                                      ],
                                  onSelected: (v) =>
                                      v == 'edit' ? onEdit() : onDelete())
                            else if (memberEvent || anniversaryEvent)
                              const Icon(Icons.open_in_new_rounded, size: 15)
                          ]),
                          Text(
                              [
                                if (event.memberName?.isNotEmpty == true)
                                  event.memberName!,
                                event.eventType,
                                ...[
                                  if (event.isApproximate)
                                    (vi ? 'ước lượng' : 'approximate'),
                                  if (event.isDerived)
                                    (vi ? 'tự động' : 'derived')
                                ]
                              ].join(' · '),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                          if (event.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 7),
                            Text(event.description!)
                          ],
                          if (event.location?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text('⌖ ${event.location}',
                                style: Theme.of(context).textTheme.bodySmall)
                          ],
                        ]))),
          )),
        ]));
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline(
      {required this.icon,
      required this.title,
      required this.detail,
      required this.action,
      required this.onAction});
  final IconData icon;
  final String title, detail;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48, color: MyLifeDesign.teal),
            const SizedBox(height: 14),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 7),
            Text(detail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            if (action != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: onAction, child: Text(action!))
            ]
          ])));
}
