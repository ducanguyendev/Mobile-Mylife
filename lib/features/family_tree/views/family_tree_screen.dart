import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../models/family_member_model.dart';
import '../providers/family_tree_provider.dart';
import '../services/family_tree_api_service.dart';
import '../widgets/member_form_bottom_sheet.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  final _search = TextEditingController();
  String _query = '';
  int? _generation;
  bool _graphView = false;
  final Map<int, Future<Uint8List>> _avatarFutures = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(familyTreeProvider.notifier).load();
      }
    });
  }

  Future<void> _showMemberForm({
    FamilyMember? member,
    FamilyMember? parentMember,
  }) async {
    final currentState = ref.read(familyTreeProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemberFormBottomSheet(
        initialMember: member,
        parentMember: parentMember,
        availableMembers: currentState.members,
        generations: currentState.generations,
        onSave: (candidate) {
          final notifier = ref.read(familyTreeProvider.notifier);
          return candidate.isDraft
              ? notifier.createMember(candidate)
              : notifier.updateMember(candidate);
        },
      ),
    );
  }

  Future<void> _confirmDelete(FamilyMember member) async {
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight,
        title: const Text('Xóa thành viên?'),
        content: Text(
          'Bạn có chắc muốn xóa ${member.fullName}? Các liên kết gia đình liên quan sẽ được cập nhật.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted =
        await ref.read(familyTreeProvider.notifier).deleteMember(member.id);
    if (deleted && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Đã xóa ${member.fullName} khỏi gia phả.')),
        );
    }
  }

  Future<void> _showDetails(FamilyMember member) async {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Center(child: _memberAvatar(member, true, radius: 42)),
                      const SizedBox(height: 10),
                      Center(
                          child: Text(member.fullName,
                              style: Theme.of(ctx)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold))),
                      Center(
                          child: Text(
                              '${vi ? 'Đời' : 'Generation'} ${member.generation} · ${member.lifeStatus == 'DECEASED' ? (vi ? 'Đã mất' : 'Deceased') : (vi ? 'Còn sống' : 'Living')}')),
                      const Divider(height: 24),
                      _detail(vi ? 'Giới tính' : 'Gender', member.gender),
                      _detail(vi ? 'Ngày sinh' : 'Date of birth',
                          member.dateOfBirth),
                      _detail(
                          vi ? 'Ngày mất' : 'Date of death', member.deathDate),
                      _detail(vi ? 'Vai trò' : 'Role', member.role),
                      _detail(vi ? 'Điện thoại' : 'Phone', member.phoneNumber),
                      _detail(vi ? 'Địa chỉ' : 'Address', member.address),
                      _detail(vi ? 'Tiểu sử' : 'Biography', member.biography),
                      _detail(vi ? 'Cha' : 'Father', member.fatherName),
                      _detail(vi ? 'Mẹ' : 'Mother', member.motherName),
                      _detail(vi ? 'Vợ/chồng' : 'Spouse', member.spouseName),
                      _detail(vi ? 'Con' : 'Children',
                          member.childNames.join(', ')),
                      _detail(
                          vi ? 'Quan hệ khác' : 'Other relations',
                          member.horizontalRelations
                              .map((r) =>
                                  '${_nameForId(r.memberId)} (${r.relationType})')
                              .join(', ')),
                      Wrap(spacing: 8, children: [
                        OutlinedButton.icon(
                            onPressed: () async {
                              final image = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 82);
                              if (image == null) return;
                              final done = await ref
                                  .read(familyTreeProvider.notifier)
                                  .uploadAvatar(member.id, File(image.path));
                              if (ctx.mounted && done) {
                                _avatarFutures.remove(member.id);
                                Navigator.pop(ctx);
                              }
                            },
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(vi ? 'Đổi ảnh' : 'Upload avatar')),
                        if (member.avatarUrl?.isNotEmpty == true)
                          OutlinedButton.icon(
                              onPressed: () async {
                                final done = await ref
                                    .read(familyTreeProvider.notifier)
                                    .deleteAvatar(member.id);
                                if (ctx.mounted && done) {
                                  _avatarFutures.remove(member.id);
                                  Navigator.pop(ctx);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: Text(vi ? 'Xoá ảnh' : 'Delete avatar'))
                      ]),
                    ])))));
  }

  String _nameForId(int id) {
    for (final m in ref.read(familyTreeProvider).members) {
      if (m.id == id) return m.fullName;
    }
    return '$id';
  }

  Widget _detail(String label, String? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700))),
        Expanded(child: Text(value?.isNotEmpty == true ? value! : '—'))
      ]));

  List<FamilyMember> _rootMembers(List<FamilyMember> members) {
    final memberIds = members.map((member) => member.id).toSet();
    final roots = members.where((member) {
      final hasKnownFather =
          member.fatherId != null && memberIds.contains(member.fatherId);
      final hasKnownMother =
          member.motherId != null && memberIds.contains(member.motherId);
      return !hasKnownFather && !hasKnownMother;
    }).toList(growable: false);

    // A malformed legacy graph should still remain inspectable rather than
    // rendering a blank page. The recursive renderer below also guards loops.
    return roots.isEmpty ? members : roots;
  }

  List<FamilyMember> _childrenOf(
    FamilyMember parent,
    List<FamilyMember> allMembers,
    Set<int> ancestors,
  ) {
    return allMembers.where((candidate) {
      if (ancestors.contains(candidate.id)) return false;
      return candidate.fatherId == parent.id ||
          candidate.motherId == parent.id ||
          parent.childIds.contains(candidate.id);
    }).toList(growable: false);
  }

  Widget _buildTreeNodes(
    List<FamilyMember> members,
    List<FamilyMember> allMembers,
    bool isDark, {
    required Set<int> ancestors,
  }) {
    if (members.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final memberAncestors = {...ancestors, member.id};
        final children = _childrenOf(member, allMembers, memberAncestors);

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              member.fullName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: _memberSubtitle(member, isDark),
            leading: _memberAvatar(member, isDark),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              if (children.isNotEmpty)
                _buildTreeNodes(
                  children,
                  allMembers,
                  isDark,
                  ancestors: memberAncestors,
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showMemberForm(parentMember: member),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Thêm con'),
                    ),
                    TextButton.icon(
                        onPressed: () => _showDetails(member),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text(
                            Localizations.localeOf(context).languageCode == 'vi'
                                ? 'Chi tiết'
                                : 'Details')),
                    TextButton.icon(
                      onPressed: () => _showMemberForm(member: member),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(member),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Xóa'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _memberSubtitle(FamilyMember member, bool isDark) {
    final details = <String>[
      if (member.role?.isNotEmpty == true) member.role!,
      'Đời ${member.generation}',
      if (member.dateOfBirth?.isNotEmpty == true) member.dateOfBirth!,
    ];
    if (details.isEmpty) return null;
    return Text(
      details.join(' • '),
      style: TextStyle(
        color: isDark ? AppColors.accentGold : AppColors.accentGoldLightMode,
        fontSize: 12,
      ),
    );
  }

  Widget _memberAvatar(FamilyMember member, bool isDark, {double radius = 20}) {
    final hasAvatar = member.avatarUrl?.isNotEmpty == true;
    return CircleAvatar(
      radius: radius,
      backgroundColor: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
      child: hasAvatar
          ? FutureBuilder<Uint8List>(
              future: _avatarFutures.putIfAbsent(
                  member.id,
                  () => ref
                      .read(familyTreeApiServiceProvider)
                      .avatarImage(member.id)),
              builder: (context, snapshot) => snapshot.hasData
                  ? ClipOval(
                      child: Image.memory(snapshot.data!,
                          width: radius * 2,
                          height: radius * 2,
                          fit: BoxFit.cover))
                  : Icon(Icons.person,
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textSecondaryLight,
                      size: radius),
            )
          : Icon(
              Icons.person,
              color:
                  isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
              size: radius,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final familyTree = ref.watch(familyTreeProvider);

    ref.listen<FamilyTreeState>(familyTreeProvider, (previous, next) {
      final error = next.errorMessage;
      if (error == null || error == previous?.errorMessage) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(error),
            ),
          );
      });
    });
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        ref.read(familyTreeProvider.notifier).clear();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryBg : AppColors.primaryBgLight,
      appBar: AppBar(
        title: const Text('Quản lý Gia phả'),
        backgroundColor:
            isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: familyTree.isLoading || familyTree.isMutating
                ? null
                : () => ref.read(familyTreeProvider.notifier).refresh(),
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: familyTree.isMutating ? null : _showMemberForm,
            tooltip: 'Thêm tổ tiên (gốc)',
          ),
        ],
      ),
      body: _buildBody(familyTree, isDark),
    );
  }

  Widget _buildBody(FamilyTreeState familyTree, bool isDark) {
    if (familyTree.isLoading && familyTree.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (familyTree.members.isEmpty && familyTree.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                familyTree.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.read(familyTreeProvider.notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final matching = familyTree.members
        .where((m) =>
            (_generation == null || m.generation == _generation) &&
            (_query.isEmpty ||
                '${m.fullName} ${m.role ?? ''} ${m.address ?? ''}'
                    .toLowerCase()
                    .contains(_query.toLowerCase())))
        .toList();
    final roots = _rootMembers(matching);
    return RefreshIndicator(
      onRefresh: () => ref.read(familyTreeProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: vi
                        ? 'Tìm theo tên, vai trò, địa chỉ'
                        : 'Search name, role, or address',
                    suffixIcon: IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear)))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<int?>(
                      initialValue: _generation,
                      decoration: InputDecoration(
                          labelText:
                              vi ? 'Lọc theo thế hệ' : 'Filter by generation'),
                      items: [
                        DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                                vi ? 'Tất cả các đời' : 'All generations')),
                        ...familyTree.generations.map((g) =>
                            DropdownMenuItem<int?>(
                                value: g.id, child: Text(g.title ?? g.name)))
                      ],
                      onChanged: (v) => setState(() => _generation = v))),
              IconButton(
                  tooltip: _graphView ? 'List view' : 'Graph view',
                  onPressed: () => setState(() => _graphView = !_graphView),
                  icon: Icon(_graphView
                      ? Icons.view_list
                      : Icons.account_tree_outlined))
            ]),
            if (familyTree.isLoading || familyTree.isMutating)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (familyTree.members.isEmpty)
              _emptyTree(isDark)
            else if (_graphView)
              _buildGraph(matching, isDark)
            else
              _buildTreeNodes(
                roots,
                matching,
                isDark,
                ancestors: const <int>{},
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph(List<FamilyMember> members, bool isDark) {
    final generations = members.map((m) => m.generation).toSet().toList()
      ..sort();
    if (members.isEmpty) return const SizedBox.shrink();
    return SizedBox(
        height: 520,
        child: InteractiveViewer(
            minScale: .35,
            maxScale: 2.5,
            constrained: false,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: generations
                    .map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 76,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 18),
                                      child: Text(
                                          '${Localizations.localeOf(context).languageCode == 'vi' ? 'Đời' : 'Gen.'} $g',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              ...members.where((m) => m.generation == g).map(
                                  (m) => SizedBox(
                                      width: 158,
                                      child: Card(
                                          child: InkWell(
                                              onTap: () => _showDetails(m),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(children: [
                                                    _memberAvatar(m, isDark,
                                                        radius: 25),
                                                    const SizedBox(height: 6),
                                                    Text(m.fullName,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Text(m.role ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    if (m.fatherName != null ||
                                                        m.motherName != null)
                                                      Text(
                                                          '↑ ${m.fatherName ?? ''} ${m.motherName ?? ''}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      10)),
                                                    if (m.childNames.isNotEmpty)
                                                      Text(
                                                          '↓ ${m.childNames.join(', ')}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10))
                                                  ]))))))
                            ])))
                    .toList())));
  }

  Widget _emptyTree(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thành viên trong gia phả.',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showMemberForm,
            icon: const Icon(Icons.person_add),
            label: const Text('Thêm thành viên đầu tiên'),
          ),
        ],
      ),
    );
  }
}
