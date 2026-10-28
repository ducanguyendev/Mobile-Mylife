import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/mylife_design_tokens.dart';
import '../models/family_member_model.dart';
import '../models/family_v2_models.dart';
import '../services/family_v2_api_service.dart';

class FamilyMemberProfileScreen extends ConsumerStatefulWidget {
  const FamilyMemberProfileScreen(
      {super.key,
      required this.member,
      required this.onEdit,
      required this.onUploadAvatar});
  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onUploadAvatar;
  @override
  ConsumerState<FamilyMemberProfileScreen> createState() =>
      _FamilyMemberProfileScreenState();
}

class _FamilyMemberProfileScreenState
    extends ConsumerState<FamilyMemberProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  late Future<FamilyMemberProfile> _profile;
  @override
  void initState() {
    super.initState();
    _profile =
        ref.read(familyV2ApiServiceProvider).getMemberProfile(widget.member.id);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final member = widget.member;
    return Scaffold(
      body: FutureBuilder<FamilyMemberProfile>(
          future: _profile,
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return NestedScrollView(
              headerSliverBuilder: (context, inner) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 300,
                  title: inner ? Text(member.fullName) : null,
                  flexibleSpace: FlexibleSpaceBar(
                      background: _ProfileHero(member: member, vi: vi)),
                  actions: [
                    IconButton(
                        tooltip: vi ? 'Đổi ảnh' : 'Change photo',
                        onPressed: widget.onUploadAvatar,
                        icon: const Icon(Icons.add_a_photo_outlined)),
                    IconButton(
                        tooltip: vi ? 'Chỉnh sửa' : 'Edit member',
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit_outlined)),
                    IconButton(
                        tooltip: vi ? 'Tải lại' : 'Refresh',
                        onPressed: () => setState(() => _profile = ref
                            .read(familyV2ApiServiceProvider)
                            .getMemberProfile(member.id)),
                        icon: const Icon(Icons.refresh_rounded)),
                  ],
                  bottom: TabBar(controller: _tabs, tabs: [
                    Tab(text: vi ? 'Famiglia' : 'Family'),
                    Tab(text: vi ? 'Percorso di vita' : 'Life'),
                    Tab(text: vi ? 'Ricordi' : 'Memories')
                  ]),
                ),
              ],
              body: snapshot.connectionState == ConnectionState.waiting &&
                      profile == null
                  ? const Center(child: CircularProgressIndicator())
                  : snapshot.hasError || profile == null
                      ? _ProfileError(
                          vi: vi,
                          onRetry: () => setState(() => _profile = ref
                              .read(familyV2ApiServiceProvider)
                              .getMemberProfile(member.id)))
                      : TabBarView(controller: _tabs, children: [
                          _familyTab(profile, vi),
                          _timelineTab(profile, vi),
                          _memoriesTab(profile, vi)
                        ]),
            );
          }),
    );
  }

  Widget _familyTab(FamilyMemberProfile profile, bool vi) {
    final member = profile.member;
    return ListView(padding: const EdgeInsets.all(20), children: [
      _ProfileSection(
          title: vi ? 'Thông tin' : 'About',
          child: Column(children: [
            _ProfileInfo(
                label: vi ? 'Ngày sinh' : 'Born', value: member.dateOfBirth),
            _ProfileInfo(
                label: vi ? 'Ngày mất' : 'Died', value: member.deathDate),
            _ProfileInfo(label: vi ? 'Vai trò' : 'Role', value: member.role),
            _ProfileInfo(
                label: vi ? 'Điện thoại' : 'Phone', value: member.phoneNumber),
            _ProfileInfo(
                label: vi ? 'Địa chỉ' : 'Address', value: member.address),
            if (member.biography?.isNotEmpty == true)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(member.biography!)),
          ])),
      const SizedBox(height: 16),
      _ProfileSection(
          title: vi ? 'Người thân' : 'Relatives',
          child: profile.relatives.isEmpty
              ? Text(vi
                  ? 'Chưa có liên kết người thân.'
                  : 'No linked relatives yet.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.relatives
                      .map((relative) => _RelativeChip(member: relative))
                      .toList())),
    ]);
  }

  Widget _timelineTab(FamilyMemberProfile profile, bool vi) =>
      profile.timeline.isEmpty
          ? _ProfileEmpty(
              icon: Icons.timeline_rounded,
              title: vi ? 'Chưa có dấu mốc' : 'No milestones yet')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final event in profile.timeline)
                _ProfileEvent(event: event, vi: vi)
            ]);
  Widget _memoriesTab(FamilyMemberProfile profile, bool vi) =>
      ListView(padding: const EdgeInsets.all(20), children: [
        _ProfileSection(
            title: vi ? 'Ngày giỗ & kỷ niệm' : 'Anniversaries',
            child: profile.anniversaries.isEmpty
                ? Text(vi
                    ? 'Chưa có ngày kỷ niệm được liên kết.'
                    : 'No linked anniversaries yet.')
                : Column(
                    children: profile.anniversaries
                        .map((e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_note_rounded,
                                color: MyLifeDesign.amber),
                            title: Text(e.title),
                            subtitle: Text(
                                '${e.nextSolarDate.day}/${e.nextSolarDate.month}/${e.nextSolarDate.year}')))
                        .toList())),
        const SizedBox(height: 14),
        _ProfileSection(
            title: vi ? 'Thư viện ảnh' : 'Photo library',
            child: Row(children: [
              Icon(
                  profile.libraryMemberLinkAvailable
                      ? Icons.photo_library_outlined
                      : Icons.photo_outlined,
                  color: MyLifeDesign.violet),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(profile.libraryMemberLinkAvailable
                      ? (vi
                          ? 'Có thể liên kết ảnh với thành viên này.'
                          : 'Photos can be linked to this member.')
                      : (vi
                          ? 'Chưa có ảnh liên kết với thành viên.'
                          : 'No photos are linked to this member yet.')))
            ])),
      ]);
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.member, required this.vi});
  final FamilyMember member;
  final bool vi;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF67735E), Color(0xFF30382F)]))),
        Positioned(
            right: -30,
            top: 25,
            child: Icon(Icons.account_tree_rounded,
                size: 210, color: Colors.white.withValues(alpha: .07))),
        Positioned(
            left: 22,
            right: 22,
            bottom: 26,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withValues(alpha: .17),
                  child: Text(
                      member.fullName.trim().isEmpty
                          ? '?'
                          : member.fullName
                              .trim()
                              .characters
                              .first
                              .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800))),
              const SizedBox(height: 13),
              Text(member.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                  '${vi ? 'Đời' : 'Generation'} ${member.generation} · ${member.lifeStatus == 'DECEASED' ? (vi ? 'Đã mất' : 'Remembered') : (vi ? 'Còn sống' : 'Living')}',
                  style: const TextStyle(color: Colors.white70)),
            ])),
      ]);
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        child
      ]));
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.label, required this.value});
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 104,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(
            child: Text(value?.isNotEmpty == true ? value! : '—',
                style: const TextStyle(fontWeight: FontWeight.w600)))
      ]));
}

class _RelativeChip extends StatelessWidget {
  const _RelativeChip({required this.member});
  final FamilyMember member;
  @override
  Widget build(BuildContext context) => Chip(
      avatar: const Icon(Icons.person_outline, size: 17),
      label: Text(
          '${member.fullName} · ${member.role ?? 'Đời ${member.generation}'}'));
}

class _ProfileEvent extends StatelessWidget {
  const _ProfileEvent({required this.event, required this.vi});
  final FamilyTimelineEvent event;
  final bool vi;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
                color: MyLifeDesign.teal, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          event.eventDate?.substring(0, 10) ??
                              event.eventYear?.toString() ??
                              (vi ? 'Chưa rõ ngày' : 'Unknown date'),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: MyLifeDesign.teal)),
                      const SizedBox(height: 5),
                      Text(event.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      if (event.description?.isNotEmpty == true)
                        Text(event.description!)
                    ])))
      ]));
}

class _ProfileEmpty extends StatelessWidget {
  const _ProfileEmpty({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 45, color: MyLifeDesign.sage),
        const SizedBox(height: 10),
        Text(title)
      ]));
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.vi, required this.onRetry});
  final bool vi;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(vi
            ? 'Không tải được hồ sơ thành viên'
            : 'Could not load member profile'),
        TextButton(onPressed: onRetry, child: Text(vi ? 'Thử lại' : 'Retry'))
      ]));
}
