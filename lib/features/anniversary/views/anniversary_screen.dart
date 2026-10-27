import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forms/mylife_form_fields.dart';
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
    final initialType = item?.eventType ?? 'FAMILY_EVENT';
    final title = TextEditingController(text: item?.title ?? '');
    final day = TextEditingController(
        text:
            initialType == 'DEATH_ANNIVERSARY' ? '${item?.lunarDay ?? 1}' : '');
    final month = TextEditingController(
        text: initialType == 'DEATH_ANNIVERSARY'
            ? '${item?.lunarMonth ?? 1}'
            : '');
    final year = TextEditingController(
        text: initialType == 'DEATH_ANNIVERSARY'
            ? item?.lunarYear?.toString() ?? ''
            : '');
    final place = TextEditingController(text: item?.place ?? '');
    final host = TextEditingController(text: item?.host ?? '');
    final notes = TextEditingController(text: item?.notes ?? '');
    var type = initialType;
    var leap = item?.isLeapMonth ?? false;
    int? memberId = item?.relatedMemberId;
    DateTime? solar = item?.originalSolarDate;
    final lang = Localizations.localeOf(context).languageCode;
    final vi = lang == 'vi';
    final formKey = GlobalKey<FormState>();
    String? dateError;
    final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                  title: Text(item == null
                      ? (vi ? 'Thêm ngày kỷ niệm' : 'Add anniversary')
                      : (vi ? 'Sửa ngày kỷ niệm' : 'Edit anniversary')),
                  content: SizedBox(
                      width: 440,
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                MyLifeSelectField<String>(
                                  label: vi ? 'Loại sự kiện' : 'Event type',
                                  value: type,
                                  items: [
                                    DropdownMenuItem(
                                        value: 'DEATH_ANNIVERSARY',
                                        child: Text(vi
                                            ? 'Ngày giỗ'
                                            : 'Death anniversary')),
                                    DropdownMenuItem(
                                        value: 'FAMILY_EVENT',
                                        child: Text(vi ? 'Sự kiện' : 'Event')),
                                  ],
                                  onChanged: (nextType) {
                                    if (nextType == null) return;
                                    update(() {
                                      type = nextType;
                                      dateError = null;
                                      if (nextType == 'FAMILY_EVENT') {
                                        day.clear();
                                        month.clear();
                                        year.clear();
                                        leap = false;
                                      } else {
                                        if (day.text.isEmpty) day.text = '1';
                                        if (month.text.isEmpty) {
                                          month.text = '1';
                                        }
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 14),
                                MyLifeTextField(
                                  label: vi ? 'Tên sự kiện' : 'Event name',
                                  controller: title,
                                  required: true,
                                  maxLength: 200,
                                  hint: vi
                                      ? 'Nhập tên sự kiện'
                                      : 'Enter an event name',
                                  validator: (value) {
                                    final text = value?.trim() ?? '';
                                    if (text.length < 2 || text.length > 200) {
                                      return vi
                                          ? 'Tên cần có từ 2 đến 200 ký tự.'
                                          : 'Enter 2 to 200 characters.';
                                    }
                                    return null;
                                  },
                                ),
                                if (tree.members.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  MyLifeSelectField<int?>(
                                    label: vi
                                        ? 'Thành viên liên quan'
                                        : 'Related family member',
                                    value: memberId,
                                    hint: vi ? 'Không chọn' : 'None',
                                    items: [
                                      DropdownMenuItem<int?>(
                                          value: null,
                                          child:
                                              Text(vi ? 'Không chọn' : 'None')),
                                      ...tree.members.map((member) =>
                                          DropdownMenuItem<int?>(
                                              value: member.id,
                                              child: Text(member.fullName,
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                    onChanged: (value) =>
                                        update(() => memberId = value),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                if (type == 'DEATH_ANNIVERSARY') ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: MyLifeTextField(
                                          label: vi ? 'Ngày âm' : 'Lunar day',
                                          controller: day,
                                          required: true,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            final number =
                                                int.tryParse(value ?? '');
                                            if (number == null ||
                                                number < 1 ||
                                                number > 30) {
                                              return vi
                                                  ? 'Nhập ngày từ 1 đến 30.'
                                                  : 'Enter a day from 1 to 30.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: MyLifeTextField(
                                          label:
                                              vi ? 'Tháng âm' : 'Lunar month',
                                          controller: month,
                                          required: true,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            final number =
                                                int.tryParse(value ?? '');
                                            if (number == null ||
                                                number < 1 ||
                                                number > 12) {
                                              return vi
                                                  ? 'Nhập tháng từ 1 đến 12.'
                                                  : 'Enter a month from 1 to 12.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  MyLifeTextField(
                                    label: vi
                                        ? 'Năm âm gốc'
                                        : 'Original lunar year',
                                    controller: year,
                                    required: true,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    validator: (value) {
                                      final number = int.tryParse(value ?? '');
                                      if (number == null ||
                                          number < 1800 ||
                                          number > 2200) {
                                        return vi
                                            ? 'Năm âm phải từ 1800 đến 2200.'
                                            : 'Lunar year must be from 1800 to 2200.';
                                      }
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final lunarYear =
                                            int.tryParse(year.text);
                                        final lunarDay = int.tryParse(day.text);
                                        final lunarMonth =
                                            int.tryParse(month.text);
                                        if (lunarYear == null ||
                                            lunarDay == null ||
                                            lunarMonth == null) {
                                          return;
                                        }
                                        try {
                                          final converted = await ref
                                              .read(anniversaryApiProvider)
                                              .convert(lunarDay, lunarMonth,
                                                  lunarYear, leap);
                                          update(() {
                                            solar = converted;
                                            dateError = null;
                                          });
                                        } catch (error) {
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(ctx)
                                                .showSnackBar(SnackBar(
                                                    content: Text(ApiError.message(
                                                        error,
                                                        fallback: vi
                                                            ? 'Không thể đổi ngày âm.'
                                                            : 'Could not convert lunar date.'))));
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.sync, size: 18),
                                      label: Text(vi
                                          ? 'Đổi âm sang dương'
                                          : 'Convert lunar date'),
                                    ),
                                  ),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title:
                                        Text(vi ? 'Tháng nhuận' : 'Leap month'),
                                    value: leap,
                                    onChanged: (value) =>
                                        update(() => leap = value),
                                  ),
                                  MyLifeDateField(
                                    label: vi
                                        ? 'Ngày mất dương lịch'
                                        : 'Original solar date',
                                    value: solar,
                                    required: true,
                                    errorText: dateError,
                                    onChanged: (value) => update(() {
                                      solar = value;
                                      dateError = null;
                                    }),
                                  ),
                                ] else
                                  MyLifeDateField(
                                    label: vi ? 'Ngày sự kiện' : 'Event date',
                                    value: solar,
                                    required: true,
                                    errorText: dateError,
                                    onChanged: (value) => update(() {
                                      solar = value;
                                      dateError = null;
                                    }),
                                  ),
                                const SizedBox(height: 14),
                                MyLifeTextField(
                                  label: type == 'DEATH_ANNIVERSARY'
                                      ? (vi
                                          ? 'Nơi tổ chức giỗ'
                                          : 'Memorial location')
                                      : (vi
                                          ? 'Địa điểm tổ chức'
                                          : 'Event location'),
                                  controller: place,
                                  maxLength: 500,
                                  prefixIcon: const Icon(Icons.place_outlined),
                                ),
                                const SizedBox(height: 14),
                                MyLifeTextField(
                                  label: type == 'DEATH_ANNIVERSARY'
                                      ? (vi
                                          ? 'Chủ lễ / Trưởng chi'
                                          : 'Officiant / Family representative')
                                      : (vi ? 'Người chủ trì' : 'Host'),
                                  controller: host,
                                  maxLength: 300,
                                  prefixIcon: const Icon(Icons.people_outline),
                                ),
                                const SizedBox(height: 14),
                                MyLifeTextArea(
                                  label: vi ? 'Ghi chú' : 'Notes',
                                  controller: notes,
                                  maxLength: 2000,
                                  hint: vi
                                      ? 'Nhập nội dung ghi chú'
                                      : 'Add a note',
                                ),
                              ])))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(vi ? 'Huỷ' : 'Cancel')),
                    FilledButton(
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          if (solar == null) {
                            update(() => dateError =
                                vi ? 'Vui lòng chọn ngày.' : 'Choose a date.');
                            return;
                          }
                          Navigator.pop(ctx, true);
                        },
                        child: Text(vi ? 'Lưu' : 'Save'))
                  ],
                )));
    if (result == true && mounted) {
      try {
        final isDeathAnniversary = type == 'DEATH_ANNIVERSARY';
        final d = isDeathAnniversary ? int.parse(day.text) : null;
        final m = isDeathAnniversary ? int.parse(month.text) : null;
        final y = isDeathAnniversary ? int.parse(year.text) : null;
        late final DateTime nextSolarDate;
        late final int daysUntil;
        int? nextLunarYear;
        if (isDeathAnniversary) {
          final next = await ref
              .read(anniversaryApiProvider)
              .nextOccurrence(d!, m!, leap);
          nextSolarDate = DateTime.parse(next['nextSolarDate'] as String);
          daysUntil = (next['daysUntil'] as num).toInt();
          nextLunarYear = (next['nextLunarYear'] as num).toInt();
        } else {
          final eventDate = solar!;
          final current = DateTime.now();
          final today = DateTime(current.year, current.month, current.day);
          DateTime nextDateForYear(int targetYear) {
            final lastDay =
                DateUtils.getDaysInMonth(targetYear, eventDate.month);
            return DateTime(targetYear, eventDate.month,
                eventDate.day > lastDay ? lastDay : eventDate.day);
          }

          var candidate = nextDateForYear(today.year);
          if (candidate.isBefore(today)) {
            candidate = nextDateForYear(today.year + 1);
          }
          nextSolarDate = candidate;
          daysUntil = candidate.difference(today).inDays;
        }
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
            isLeapMonth: isDeathAnniversary && leap,
            originalSolarDate: solar,
            lunarYear: y,
            nextLunarYear: nextLunarYear,
            nextSolarDate: nextSolarDate,
            daysUntil: daysUntil,
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

  String _eventSubtitle(FamilyAnniversary event, String lang, bool vi) {
    final details = <String>[
      if (event.relatedMemberName != null) event.relatedMemberName!,
      DateFormat.yMMMd(lang).format(event.nextSolarDate),
      if (event.place != null)
        '${vi ? 'Địa điểm' : 'Location'}: ${event.place}',
      '${vi ? 'Còn' : 'In'} ${event.daysUntil} ${vi ? 'ngày' : 'days'}',
      if (event.eventType == 'DEATH_ANNIVERSARY' &&
          event.lunarDay != null &&
          event.lunarMonth != null)
        '${vi ? 'Âm lịch' : 'Lunar'} ${event.lunarDay}/${event.lunarMonth}${event.isLeapMonth ? '*' : ''}${event.lunarYear == null ? '' : ' · ${vi ? 'Năm gốc' : 'Original year'} ${event.lunarYear}'}',
      if (event.originalSolarDate != null)
        '${vi ? 'Ngày dương gốc' : 'Original solar date'} ${DateFormat.yMd(lang).format(event.originalSolarDate!)}',
      if (event.host != null) '${vi ? 'Chủ trì' : 'Host'}: ${event.host}',
      if (event.notes != null) event.notes!,
    ];
    return details.join('\n');
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
                          subtitle:
                              Text(_eventSubtitle(e, lang, vi), maxLines: 4),
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
