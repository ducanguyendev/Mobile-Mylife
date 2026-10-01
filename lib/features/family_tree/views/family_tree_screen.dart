import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../models/family_member_model.dart';
import '../widgets/member_form_bottom_sheet.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  // Mock data representing the family tree
  List<FamilyMember> rootMembers = [
    FamilyMember(
      id: '1',
      name: 'Nguyễn Văn A (Ông nội)',
      title: 'Trưởng tộc',
      birthDate: '1940',
      children: [
        FamilyMember(
          id: '2',
          name: 'Nguyễn Văn B (Bác cả)',
          parentId: '1',
          children: [
            FamilyMember(id: '4', name: 'Nguyễn Thị C', parentId: '2'),
            FamilyMember(id: '5', name: 'Nguyễn Văn D', parentId: '2'),
          ],
        ),
        FamilyMember(
          id: '3',
          name: 'Nguyễn Văn E (Bố)',
          parentId: '1',
          children: [
            FamilyMember(id: '6', name: 'Tôi', parentId: '3'),
          ],
        ),
      ],
    ),
  ];

  void _showMemberForm({FamilyMember? member, String? parentId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemberFormBottomSheet(
        initialMember: member,
        parentId: parentId,
        onSave: (newMember) {
          // TODO: Add logic to update tree
          setState(() {
            // Mock save logic
          });
        },
      ),
    );
  }

  Widget _buildTreeNodes(List<FamilyMember> members, bool isDark) {
    if (members.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              member.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: member.title != null 
                ? Text(member.title!, style: TextStyle(color: isDark ? AppColors.accentGold : AppColors.accentGoldLightMode, fontSize: 12)) 
                : null,
            leading: CircleAvatar(
              backgroundColor: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
              child: Icon(Icons.person, color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight),
            ),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              if (member.children.isNotEmpty) _buildTreeNodes(member.children, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showMemberForm(parentId: member.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Thêm con'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showMemberForm(member: member),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: TextButton.styleFrom(foregroundColor: Colors.orange),
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

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryBg : AppColors.primaryBgLight,
      appBar: AppBar(
        title: const Text('Quản lý Gia phả'),
        backgroundColor: isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showMemberForm(),
            tooltip: 'Thêm tổ tiên (Root)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildTreeNodes(rootMembers, isDark),
      ),
    );
  }
}
