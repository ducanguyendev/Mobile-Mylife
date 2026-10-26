import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/theme/app_colors.dart';
import '../../family_tree/providers/family_tree_provider.dart';
import '../models/family_anniversary.dart';
import '../providers/anniversary_provider.dart';
import '../services/anniversary_api_service.dart';

class AnniversaryScreen extends ConsumerStatefulWidget {
  const AnniversaryScreen({super.key});
  @override
  ConsumerState<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends ConsumerState<AnniversaryScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(familyTreeProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  List<FamilyAnniversary> _visible(List<FamilyAnniversary> all) => all
      .where((e) =>
          (_query.isEmpty ||
              '${e.title} ${e.relatedMemberName ?? ''} ${e.place ?? ''} ${e.host ?? ''}'
                  .toLowerCase()
                  .contains(_query.toLowerCase())) &&
          (_selected == null || _sameDay(e.nextSolarDate, _selected!)))
      .toList()
    ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  Future<void> _edit([FamilyAnniversary? item]) async {
    if (item == null && ref.read(familyTreeProvider).members.isEmpty) {
      await ref.read(familyTreeProvider.notifier).load();
      if (!mounted) return;
    }
    final tree = ref.read(familyTreeProvider);
    final title = TextEditingController(text: item?.title ?? '');
    final day = TextEditingController(text: '${item?.lunarDay ?? 1}');
    final month = TextEditingController(text: '${item?.lunarMonth ?? 1}');
    final year = TextEditingController(text: item?.lunarYear?.toString() ?? '');
    final place = TextEditingController(text: item?.place ?? '');
    final host = TextEditingController(text: item?.host ?? '');
    final notes = TextEditingController(text: item?.notes ?? '');
    var type = item?.eventType ?? 'FAMILY_EVENT';
    var leap = item?.isLeapMonth ?? false;
    int? memberId = item?.relatedMemberId;
    DateTime? solar = item?.originalSolarDate;
    final lang = Localizations.localeOf(context).languageCode;
    final vi = lang == 'vi';
    final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                  title: Text(item == null
                      ? (vi ? 'Thêm ngày kỷ niệm' : 'Add anniversary')
                      : (vi ? 'Sửa ngày kỷ niệm' : 'Edit anniversary')),
                  content: SizedBox(
                      width: 440,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        DropdownButtonFormField<String>(
                            initialValue: type,
                            decoration: InputDecoration(
                                labelText: vi ? 'Loại sự kiện' : 'Event type'),
                            items: [
                              DropdownMenuItem(
                                  value: 'DEATH_ANNIVERSARY',
                                  child: Text(
                                      vi ? 'Ngày giỗ' : 'Death anniversary')),
                              DropdownMenuItem(
                                  value: 'FAMILY_EVENT',
                                  child: Text(
                                      vi ? 'Sự kiện gia đình' : 'Family event'))
                            ],
                            onChanged: (v) => update(() => type = v ?? type)),
                        TextField(
                            controller: title,
                            decoration: InputDecoration(
                                labelText: vi ? 'Tiêu đề' : 'Title')),
                        if (tree.members.isNotEmpty)
                          DropdownButtonFormField<int?>(
                              initialValue: memberId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: vi
                                      ? 'Thành viên liên quan'
                                      : 'Related family member'),
                              items: [
                                DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(vi ? 'Không chọn' : 'None')),
                                ...tree.members.map((m) =>
                                    DropdownMenuItem<int?>(
                                        value: m.id,
                                        child: Text(m.fullName,
                                            overflow: TextOverflow.ellipsis)))
                              ],
                              onChanged: (v) => update(() => memberId = v)),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: day,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText:
                                          vi ? 'Ngày âm' : 'Lunar day'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: month,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText:
                                          vi ? 'Tháng âm' : 'Lunar month')))
                        ]),
                        TextField(
                            controller: year,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: vi
                                    ? 'Năm âm gốc (tuỳ chọn)'
                                    : 'Original lunar year (optional)')),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: () async {
                                  final y = int.tryParse(year.text),
                                      d = int.tryParse(day.text),
                                      m = int.tryParse(month.text);
                                  if (y == null || d == null || m == null) {
                                    return;
                                  }
                                  try {
                                    final converted = await ref
                                        .read(anniversaryApiProvider)
                                        .convert(d, m, y, leap);
                                    update(() => solar = converted);
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                              content: Text(ApiError.message(e,
                                                  fallback: vi
                                                      ? 'Không thể đổi ngày âm.'
                                                      : 'Could not convert lunar date.'))));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.sync),
                                label: Text(vi
                                    ? 'Đổi âm sang dương'
                                    : 'Convert lunar date'))),
                        SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(vi ? 'Tháng nhuận' : 'Leap month'),
                            value: leap,
                            onChanged: (v) => update(() => leap = v)),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: () async {
                                  final d = await showDatePicker(
                                      context: ctx,
                                      initialDate: solar ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2200));
                                  if (d != null) update(() => solar = d);
                                },
                                icon: const Icon(Icons.calendar_month),
                                label: Text(solar == null
                                    ? (vi
                                        ? 'Ngày dương gốc'
                                        : 'Original solar date')
                                    : DateFormat.yMMMd(lang).format(solar!)))),
                        TextField(
                            controller: place,
                            decoration: InputDecoration(
                                labelText: vi ? 'Địa điểm' : 'Place')),
                        TextField(
                            controller: host,
                            decoration: InputDecoration(
                                labelText: vi ? 'Người chủ trì' : 'Host')),
                        TextField(
                            controller: notes,
                            maxLines: 2,
                            decoration: InputDecoration(
                                labelText: vi ? 'Ghi chú' : 'Notes')),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(vi ? 'Huỷ' : 'Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(vi ? 'Lưu' : 'Save'))
                  ],
                )));
    if (result == true && mounted) {
      final d = int.tryParse(day.text) ?? 0,
          m = int.tryParse(month.text) ?? 0,
          y = int.tryParse(year.text);
      try {
        final next =
            await ref.read(anniversaryApiProvider).nextOccurrence(d, m, leap);
        final event = FamilyAnniversary(
            id: item?.id ?? 0,
            eventType: type,
            title: title.text.trim(),
            relatedMemberId: memberId,
            relatedMemberName: item?.relatedMemberName,
            relatedMemberGeneration: item?.relatedMemberGeneration,
            relatedMemberRole: item?.relatedMemberRole,
            lunarDay: d,
            lunarMonth: m,
            isLeapMonth: leap,
            originalSolarDate: solar,
            lunarYear: y,
            nextLunarYear: (next['nextLunarYear'] as num).toInt(),
            nextSolarDate: DateTime.parse(next['nextSolarDate'] as String),
            daysUntil: (next['daysUntil'] as num).toInt(),
            place: place.text,
            host: host.text,
            notes: notes.text);
        await ref.read(anniversaryProvider.notifier).save(event);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
    title.dispose();
    day.dispose();
    month.dispose();
    year.dispose();
    place.dispose();
    host.dispose();
    notes.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final vi = lang == 'vi';
    final async = ref.watch(anniversaryProvider);
    final familyTree = ref.watch(familyTreeProvider);
    final events = async.valueOrNull ?? const <FamilyAnniversary>[];
    final shown = _visible(events);
    final grouped = <DateTime, List<FamilyAnniversary>>{};
    for (final e in events) {
      final d = DateTime(
          e.nextSolarDate.year, e.nextSolarDate.month, e.nextSolarDate.day);
      (grouped[d] ??= []).add(e);
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(vi ? 'Ngày kỷ niệm' : 'Anniversaries'),
            actions: [
              IconButton(
                  onPressed: familyTree.isLoading ? null : () => _edit(),
                  icon: const Icon(Icons.add),
                  tooltip: vi ? 'Thêm sự kiện' : 'Add event')
            ]),
        body: async.isLoading && events.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(anniversaryProvider.notifier).refresh(),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  if (async.hasError)
                    Card(
                        child: ListTile(
                            leading: const Icon(Icons.error_outline,
                                color: AppColors.error),
                            title: Text(vi
                                ? 'Không tải được ngày kỷ niệm'
                                : 'Could not load anniversaries'),
                            subtitle: Text(ApiError.message(async.error!,
                                fallback: vi
                                    ? 'Đã xảy ra lỗi.'
                                    : 'Something went wrong.')),
                            trailing: IconButton(
                                onPressed: () => ref
                                    .read(anniversaryProvider.notifier)
                                    .refresh(),
                                icon: const Icon(Icons.refresh)))),
                  TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: vi ? 'Tìm kiếm sự kiện' : 'Search events',
                          suffixIcon: IconButton(
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.clear)))),
                  const SizedBox(height: 12),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TableCalendar<FamilyAnniversary>(
                              locale: vi ? 'vi_VN' : 'en_US',
                              firstDay: DateTime.utc(1900),
                              lastDay: DateTime.utc(2200),
                              focusedDay: _focused,
                              selectedDayPredicate: (d) =>
                                  _selected != null && _sameDay(d, _selected!),
                              eventLoader: (d) =>
                                  grouped[DateTime(d.year, d.month, d.day)] ??
                                  const [],
                              onDaySelected: (selected, focused) {
                                setState(() => _selected = selected);
                                _focused = focused;
                              },
                              onPageChanged: (d) => _focused = d,
                              calendarStyle: const CalendarStyle(
                                  markerDecoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      shape: BoxShape.circle),
                                  todayDecoration: BoxDecoration(
                                      color: AppColors.accentGoldDark,
                                      shape: BoxShape.circle))))),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                        child: Text(
                            _selected == null
                                ? (vi ? 'Sắp tới' : 'Upcoming')
                                : DateFormat.yMMMMd(lang).format(_selected!),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                    if (_selected != null)
                      TextButton(
                          onPressed: () => setState(() => _selected = null),
                          child: Text(vi ? 'Bỏ lọc' : 'Clear'))
                  ]),
                  if (shown.isEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                            child: Text(events.isEmpty
                                ? (vi
                                    ? 'Chưa có sự kiện nào.'
                                    : 'No events yet.')
                                : (vi
                                    ? 'Không có sự kiện phù hợp.'
                                    : 'No matching events.')))),
                  ...shown.map((e) => Card(
                      child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.accentGold.withValues(alpha: .15),
                              child: Icon(
                                  e.eventType == 'DEATH_ANNIVERSARY'
                                      ? Icons.local_florist
                                      : Icons.celebration,
                                  color: AppColors.accentGoldDark)),
                          title: Text(e.title),
                          subtitle: Text(
                              '${e.relatedMemberName ?? ''}${e.relatedMemberName == null ? '' : ' · '}${DateFormat.yMMMd(lang).format(e.nextSolarDate)}${e.place == null ? '' : ' · ${e.place}'}\n${vi ? 'Còn' : 'In'} ${e.daysUntil} ${vi ? 'ngày' : 'days'} · ${vi ? 'Âm lịch' : 'Lunar'} ${e.lunarDay}/${e.lunarMonth}${e.isLeapMonth ? '*' : ''}${e.lunarYear == null ? '' : ' · ${vi ? 'Năm gốc' : 'Original year'} ${e.lunarYear}'}${e.originalSolarDate == null ? '' : ' · ${vi ? 'Dương lịch gốc' : 'Original solar'} ${DateFormat.yMd(lang).format(e.originalSolarDate!)}'}${e.host == null ? '' : ' · ${vi ? 'Chủ trì' : 'Host'} ${e.host}'}${e.notes == null ? '' : ' · ${e.notes}'}',
                              maxLines: 4),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  _edit(e);
                                }
                                if (v == 'delete') {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    await ref
                                        .read(anniversaryProvider.notifier)
                                        .delete(e.id);
                                  } catch (err) {
                                    if (mounted) {
                                      messenger.showSnackBar(SnackBar(
                                          content:
                                              Text(ApiError.message(err))));
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                    PopupMenuItem(
                                        value: 'edit',
                                        child: Text(vi ? 'Sửa' : 'Edit')),
                                    PopupMenuItem(
                                        value: 'delete',
                                        child: Text(vi ? 'Xoá' : 'Delete'))
                                  ])))),
                ])));
  }
}
