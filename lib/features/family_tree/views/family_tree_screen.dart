import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../models/family_member_model.dart';
import '../providers/family_tree_provider.dart';
import '../services/family_tree_api_service.dart';
import 'family_member_profile_screen.dart';
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
  String _viewMode = 'list';
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
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FamilyMemberProfileScreen(
        member: member,
        onEdit: () {
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showMemberForm(member: member);
          });
        },
        onUploadAvatar: () async {
          final image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 82,
          );
          if (image == null || !mounted) return;
          final done = await ref
              .read(familyTreeProvider.notifier)
              .uploadAvatar(member.id, File(image.path));
          if (done && mounted) {
            _avatarFutures.remove(member.id);
            setState(() {});
          }
        },
      ),
    ));
  }

  Widget _memberListItem(FamilyMember member, bool isDark, bool vi) {
    final secondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final parents = [member.fatherName, member.motherName]
        .where((name) => name?.isNotEmpty == true)
        .join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(member),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            _memberAvatar(member, isDark, radius: 26),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                      [
                        if (member.role?.isNotEmpty == true) member.role!,
                        '${vi ? 'Đời' : 'Gen.'} ${member.generation}',
                        if (member.dateOfBirth?.isNotEmpty == true)
                          member.dateOfBirth!
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 12)),
                  if (parents.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${vi ? 'Cha mẹ' : 'Parents'}: $parents',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: secondary, fontSize: 12))),
                ])),
            PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') _showMemberForm(member: member);
                  if (action == 'delete') _confirmDelete(member);
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'edit', child: Text(vi ? 'Sửa' : 'Edit')),
                      PopupMenuItem(
                          value: 'delete', child: Text(vi ? 'Xóa' : 'Delete'))
                    ]),
          ]),
        ),
      ),
    );
  }

  Widget _memberCard(FamilyMember member, bool isDark, bool vi) {
    final secondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final parents = [member.fatherName, member.motherName]
        .where((name) => name?.isNotEmpty == true)
        .join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: () => _showDetails(member),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _memberAvatar(member, isDark, radius: 27),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.accentGold
                                : AppColors.accentGoldLightMode)
                            .withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${vi ? 'Đời' : 'Gen.'} ${member.generation}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.accentGold
                                : AppColors.accentGoldLightMode)))
              ]),
              const SizedBox(height: 12),
              Text(member.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              if (member.role?.isNotEmpty == true)
                Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(member.role!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: secondary))),
              const SizedBox(height: 10),
              if (parents.isNotEmpty)
                Text('${vi ? 'Cha mẹ' : 'Parents'}: $parents',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondary, fontSize: 12)),
              const SizedBox(height: 14),
              Row(children: [
                Icon(Icons.child_care_outlined, size: 16, color: secondary),
                const SizedBox(width: 5),
                Text('${member.childIds.length} ${vi ? 'con' : 'children'}',
                    style: TextStyle(color: secondary, fontSize: 12)),
                const Spacer(),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: vi ? 'Sửa' : 'Edit',
                    onPressed: () => _showMemberForm(member: member),
                    icon: const Icon(Icons.edit_outlined, size: 19)),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: vi ? 'Xóa' : 'Delete',
                    onPressed: () => _confirmDelete(member),
                    icon: const Icon(Icons.delete_outline,
                        size: 19, color: AppColors.error))
              ]),
            ]),
          )),
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
            ]),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: 'tree',
                    icon: const Icon(Icons.account_tree_outlined),
                    label: Text(vi ? 'Cây' : 'Tree')),
                ButtonSegment(
                    value: 'cards',
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(vi ? 'Thẻ' : 'Cards')),
                ButtonSegment(
                    value: 'list',
                    icon: const Icon(Icons.view_list_rounded),
                    label: Text(vi ? 'Danh sách' : 'List')),
              ],
              selected: {_viewMode},
              onSelectionChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _viewMode = value.first);
              },
            ),
            if (familyTree.isLoading || familyTree.isMutating)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (familyTree.members.isEmpty)
              _emptyTree(isDark)
            else if (_viewMode == 'tree')
              _buildTree(matching, isDark, vi)
            else if (_viewMode == 'cards')
              _buildCards(matching, isDark, vi)
            else
              ...matching.map((member) => _memberListItem(member, isDark, vi))
          ],
        ),
      ),
    );
  }

  Widget _buildCards(List<FamilyMember> members, bool isDark, bool vi) {
    final generations =
        members.map((member) => member.generation).toSet().toList()..sort();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final generation in generations) ...[
        Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Text('${vi ? 'ĐỜI' : 'GENERATION'} $generation',
                style: TextStyle(
                    color: isDark
                        ? AppColors.accentGold
                        : AppColors.accentGoldLightMode,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8))),
        LayoutBuilder(builder: (context, constraints) {
          const spacing = 10.0;
          final columns = constraints.maxWidth < 360 ? 1 : 2;
          final cardWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          final generationMembers = members
              .where((member) => member.generation == generation)
              .toList(growable: false);

          return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: generationMembers
                  .map((member) => SizedBox(
                      width: cardWidth, child: _memberCard(member, isDark, vi)))
                  .toList(growable: false));
        }),
      ],
    ]);
  }

  Widget _buildTree(List<FamilyMember> members, bool isDark, bool vi) {
    final generations =
        members.map((member) => member.generation).toSet().toList()..sort();
    final allMembers = ref.read(familyTreeProvider).members;
    final widestGeneration = generations
        .map((generation) =>
            members.where((member) => member.generation == generation).length)
        .fold<int>(1, (widest, count) => count > widest ? count : widest);
    return Container(
      height: 380,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A16) : const Color(0xFFEDEDE5),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        minScale: .55,
        maxScale: 2.4,
        boundaryMargin: const EdgeInsets.all(100),
        child: SizedBox(
          width: (widestGeneration * 150).toDouble(),
          height: (generations.length.clamp(1, 5) * 116).toDouble(),
          child: Stack(children: [
            Positioned.fill(
                child: CustomPaint(
                    painter: _TreeConnectionPainter(
                        members: members,
                        allMembers: allMembers,
                        generations: generations,
                        isDark: isDark))),
            for (var gi = 0; gi < generations.length; gi++)
              for (var mi = 0;
                  mi <
                      members
                          .where((m) => m.generation == generations[gi])
                          .length;
                  mi++)
                _TreeNode(
                  member: members
                      .where((m) => m.generation == generations[gi])
                      .elementAt(mi),
                  left: 18 + mi * 150,
                  top: 14 + gi * 116,
                  isDark: isDark,
                  onTap: () => _showDetails(members
                      .where((m) => m.generation == generations[gi])
                      .elementAt(mi)),
                ),
          ]),
        ),
      ),
    );
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

class _TreeNode extends StatelessWidget {
  const _TreeNode(
      {required this.member,
      required this.left,
      required this.top,
      required this.isDark,
      required this.onTap});
  final FamilyMember member;
  final double left, top;
  final bool isDark;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        top: top,
        child: SizedBox(
            width: 128,
            child: Material(
              color: isDark ? const Color(0xFF242820) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
                    child: Column(children: [
                      CircleAvatar(
                          radius: 21,
                          backgroundColor:
                              const Color(0xFF78866B).withValues(alpha: .2),
                          child: Text(
                              member.fullName.trim().isEmpty
                                  ? '?'
                                  : member.fullName
                                      .trim()
                                      .characters
                                      .first
                                      .toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFF78866B),
                                  fontWeight: FontWeight.w800))),
                      const SizedBox(height: 7),
                      Text(member.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('Đời ${member.generation}',
                          style: Theme.of(context).textTheme.labelSmall),
                    ])),
              ),
            )),
      );
}

class _TreeConnectionPainter extends CustomPainter {
  const _TreeConnectionPainter(
      {required this.members,
      required this.allMembers,
      required this.generations,
      required this.isDark});
  final List<FamilyMember> members, allMembers;
  final List<int> generations;
  final bool isDark;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF78866B) : const Color(0xFF8A987C))
          .withValues(alpha: .55)
      ..strokeWidth = 1.5;
    final positions = <int, Offset>{};
    for (var gi = 0; gi < generations.length; gi++) {
      final row =
          members.where((m) => m.generation == generations[gi]).toList();
      for (var mi = 0; mi < row.length; mi++) {
        positions[row[mi].id] = Offset(18 + mi * 150 + 64, 14 + gi * 116 + 72);
      }
    }
    for (final child in members) {
      final childPosition = positions[child.id];
      if (childPosition == null) continue;
      for (final parentId
          in [child.fatherId, child.motherId].whereType<int>()) {
        final parentPosition = positions[parentId];
        if (parentPosition != null) {
          canvas.drawLine(parentPosition.translate(0, 24),
              childPosition.translate(0, -23), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeConnectionPainter oldDelegate) =>
      members != oldDelegate.members || isDark != oldDelegate.isDark;
}
