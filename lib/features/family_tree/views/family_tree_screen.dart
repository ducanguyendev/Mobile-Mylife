import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../models/family_member_model.dart';
import '../providers/family_tree_provider.dart';
import '../widgets/member_form_bottom_sheet.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
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

  Widget _memberAvatar(FamilyMember member, bool isDark) {
    final avatarUri = Uri.tryParse(member.avatarUrl ?? '');
    final hasRemoteAvatar = avatarUri != null && avatarUri.hasScheme;
    return CircleAvatar(
      backgroundColor: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
      backgroundImage: hasRemoteAvatar ? NetworkImage(member.avatarUrl!) : null,
      child: hasRemoteAvatar
          ? null
          : Icon(
              Icons.person,
              color:
                  isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
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

    final roots = _rootMembers(familyTree.members);
    return RefreshIndicator(
      onRefresh: () => ref.read(familyTreeProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (familyTree.isLoading || familyTree.isMutating)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (familyTree.members.isEmpty)
              _emptyTree(isDark)
            else
              _buildTreeNodes(
                roots,
                familyTree.members,
                isDark,
                ancestors: const <int>{},
              ),
          ],
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
