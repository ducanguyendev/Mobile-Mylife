import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../models/family_member_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/cyber_button.dart';

class MemberFormBottomSheet extends ConsumerStatefulWidget {
  final FamilyMember? initialMember;
  final String? parentId;
  final Function(FamilyMember) onSave;

  const MemberFormBottomSheet({
    super.key,
    this.initialMember,
    this.parentId,
    required this.onSave,
  });

  @override
  ConsumerState<MemberFormBottomSheet> createState() => _MemberFormBottomSheetState();
}

class _MemberFormBottomSheetState extends ConsumerState<MemberFormBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _birthDateController;
  late TextEditingController _deathDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialMember?.name ?? '');
    _titleController = TextEditingController(text: widget.initialMember?.title ?? '');
    _birthDateController = TextEditingController(text: widget.initialMember?.birthDate ?? '');
    _deathDateController = TextEditingController(text: widget.initialMember?.deathDate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _birthDateController.dispose();
    _deathDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    
    final member = FamilyMember(
      id: widget.initialMember?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      deathDate: _deathDateController.text.trim(),
      parentId: widget.parentId ?? widget.initialMember?.parentId,
    );

    widget.onSave(member);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final primaryBg = isDark ? AppColors.primaryBg : AppColors.primaryBgLight;
    final secondaryBg = isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight;
    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: primaryBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: secondaryBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialMember == null ? 'Thêm thành viên mới' : 'Cập nhật thành viên',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Họ và Tên (*)',
                      hint: 'Nhập họ và tên',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _titleController,
                      label: 'Danh xưng (Title)',
                      hint: 'VD: Trưởng tộc, Con trưởng...',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _birthDateController,
                      label: 'Ngày sinh',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _deathDateController,
                      label: 'Ngày mất (nếu có)',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 24),
                    
                    CyberButton(
                      text: widget.initialMember == null ? 'LƯU THÀNH VIÊN' : 'CẬP NHẬT',
                      icon: Icons.save,
                      primaryColor: accentColor,
                      height: 50,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
