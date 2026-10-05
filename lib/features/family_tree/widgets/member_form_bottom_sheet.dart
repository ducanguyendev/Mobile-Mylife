import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/cyber_button.dart';
import '../models/family_member_model.dart';

class MemberFormBottomSheet extends ConsumerStatefulWidget {
  final FamilyMember? initialMember;
  final FamilyMember? parentMember;
  final List<FamilyMember> availableMembers;
  final List<FamilyGeneration> generations;
  final Future<bool> Function(FamilyMember member) onSave;

  const MemberFormBottomSheet({
    super.key,
    this.initialMember,
    this.parentMember,
    required this.availableMembers,
    required this.generations,
    required this.onSave,
  });

  @override
  ConsumerState<MemberFormBottomSheet> createState() =>
      _MemberFormBottomSheetState();
}

class _MemberFormBottomSheetState extends ConsumerState<MemberFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _roleController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _facebookUrlController;
  late final TextEditingController _instagramUrlController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _biographyController;
  late int _generation;
  String? _gender;
  int? _fatherId;
  int? _motherId;
  int? _spouseId;
  List<int> _childIds = const [];
  List<HorizontalRelation> _horizontalRelations = const [];
  bool _isSaving = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    final member = widget.initialMember;
    _fullNameController = TextEditingController(text: member?.fullName ?? '');
    _roleController = TextEditingController(text: member?.role ?? '');
    _dateOfBirthController =
        TextEditingController(text: member?.dateOfBirth ?? '');
    _addressController = TextEditingController(text: member?.address ?? '');
    _phoneNumberController =
        TextEditingController(text: member?.phoneNumber ?? '');
    _facebookUrlController =
        TextEditingController(text: member?.facebookUrl ?? '');
    _instagramUrlController =
        TextEditingController(text: member?.instagramUrl ?? '');
    _avatarUrlController = TextEditingController(text: member?.avatarUrl ?? '');
    _biographyController = TextEditingController(text: member?.biography ?? '');

    final parentGeneration = widget.parentMember?.generation;
    _generation = member?.generation ??
        (parentGeneration != null
            ? parentGeneration + 1
            : _generationOptions.first.id);
    _gender = _selectableGender(member?.gender);
    _fatherId = _knownMemberId(member?.fatherId);
    _motherId = _knownMemberId(member?.motherId);
    _spouseId = _knownMemberId(member?.spouseId);
    _childIds = List<int>.from(member?.childIds ?? const []);
    _horizontalRelations = List<HorizontalRelation>.from(
      member?.horizontalRelations ?? const [],
    );

    // "Add child" keeps the existing quick action but maps it to the real API
    // relationship fields, rather than inventing a local parentId field.
    final parent = widget.parentMember;
    if (member == null && parent != null) {
      if (parent.isFemale) {
        _motherId = parent.id;
      } else {
        _fatherId = parent.id;
      }
    }
  }

  List<FamilyGeneration> get _generationOptions {
    final options = widget.generations.where((item) => item.id > 0).toList();
    if (options.isNotEmpty) return options;
    return List<FamilyGeneration>.generate(
      5,
      (index) => FamilyGeneration(
        id: index + 1,
        name: 'Đời ${index + 1}',
      ),
      growable: false,
    );
  }

  int? _knownMemberId(int? id) {
    if (id == null) return null;
    return widget.availableMembers.any((member) => member.id == id) ? id : null;
  }

  String? _selectableGender(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'male':
      case 'nam':
        return 'male';
      case 'female':
      case 'nữ':
      case 'nu':
        return 'female';
      case 'other':
      case 'khác':
      case 'khac':
        return 'other';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _roleController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _facebookUrlController.dispose();
    _instagramUrlController.dispose();
    _avatarUrlController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _submitError = null;
    });

    final existing = widget.initialMember;
    final member = FamilyMember(
      id: existing?.id ?? 0,
      fullName: _fullNameController.text.trim(),
      generation: _generation,
      gender: _emptyToNull(_gender),
      dateOfBirth: _emptyToNull(_dateOfBirthController.text),
      role: _emptyToNull(_roleController.text),
      address: _emptyToNull(_addressController.text),
      phoneNumber: _emptyToNull(_phoneNumberController.text),
      facebookUrl: _emptyToNull(_facebookUrlController.text),
      instagramUrl: _emptyToNull(_instagramUrlController.text),
      avatarUrl: _emptyToNull(_avatarUrlController.text),
      biography: _emptyToNull(_biographyController.text),
      fatherId: _fatherId,
      motherId: _motherId,
      spouseId: _spouseId,
      childIds: _childIds,
      horizontalRelations: _horizontalRelations,
    );

    bool saved;
    try {
      saved = await widget.onSave(member);
    } catch (error, stackTrace) {
      debugPrint('Unable to save family member: $error\n$stackTrace');
      saved = false;
    }
    if (!mounted) return;

    if (saved) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = false;
      _submitError =
          'Không thể lưu thành viên. Vui lòng kiểm tra dữ liệu và thử lại.';
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên là bắt buộc';
    }
    if (value.trim().length > 100) {
      return 'Họ và tên không được vượt quá 100 ký tự';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ||
        DateTime.tryParse(text) == null) {
      return 'Dùng định dạng YYYY-MM-DD';
    }
    return null;
  }

  List<FamilyMember> get _parentOptions {
    final currentId = widget.initialMember?.id;
    return widget.availableMembers
        .where((member) => member.id != currentId)
        .toList(growable: false);
  }

  List<FamilyMember> get _spouseOptions {
    final currentId = widget.initialMember?.id;
    return widget.availableMembers.where((member) {
      return member.id != currentId &&
          (member.spouseId == null || member.spouseId == currentId);
    }).toList(growable: false);
  }

  List<FamilyMember> get _relatedMemberOptions {
    final currentId = widget.initialMember?.id;
    return widget.availableMembers
        .where((member) => member.id != currentId)
        .toList(growable: false);
  }

  Future<void> _editChildren() async {
    final selected = Set<int>.from(_childIds);
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chọn con cái'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
            child: _relatedMemberOptions.isEmpty
                ? const Text('Chưa có thành viên nào để liên kết.')
                : ListView(
                    shrinkWrap: true,
                    children: _relatedMemberOptions
                        .map(
                          (candidate) => CheckboxListTile(
                            value: selected.contains(candidate.id),
                            title: Text(candidate.fullName),
                            subtitle: Text('Đời ${candidate.generation}'),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked ?? false) {
                                  selected.add(candidate.id);
                                } else {
                                  selected.remove(candidate.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(selected),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final childIds = result.toList()..sort();
      setState(() => _childIds = childIds);
    }
  }

  Future<void> _addHorizontalRelation() async {
    int? relatedMemberId;
    final relationTypeController = TextEditingController();
    try {
      final relation = await showDialog<HorizontalRelation>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Thêm quan hệ ngang'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: relatedMemberId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Thành viên'),
                    items: _relatedMemberOptions
                        .map(
                          (member) => DropdownMenuItem<int>(
                            value: member.id,
                            child: Text(member.fullName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => setDialogState(
                      () => relatedMemberId = value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: relationTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Loại quan hệ',
                      hintText: 'Ví dụ: anh/chị/em, cô/dì/chú/bác',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () {
                  final type = relationTypeController.text.trim();
                  if (relatedMemberId == null || type.isEmpty) return;
                  Navigator.of(dialogContext).pop(
                    HorizontalRelation(
                      memberId: relatedMemberId!,
                      relationType: type,
                    ),
                  );
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
        ),
      );

      if (relation != null && mounted) {
        setState(() {
          final alreadyExists = _horizontalRelations.any(
            (item) =>
                item.memberId == relation.memberId &&
                item.relationType.toLowerCase() ==
                    relation.relationType.toLowerCase(),
          );
          if (!alreadyExists) {
            _horizontalRelations = [..._horizontalRelations, relation];
          }
        });
      }
    } finally {
      relationTypeController.dispose();
    }
  }

  void _removeHorizontalRelation(HorizontalRelation relation) {
    setState(() {
      _horizontalRelations = _horizontalRelations
          .where(
            (item) =>
                item.memberId != relation.memberId ||
                item.relationType != relation.relationType,
          )
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final primaryBg = isDark ? AppColors.primaryBg : AppColors.primaryBgLight;
    final secondaryBg =
        isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight;
    final accentColor =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: primaryBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.initialMember == null
                                ? 'Thêm thành viên mới'
                                : 'Cập nhật thành viên',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Họ và tên (*)',
                          hint: 'Nhập họ và tên',
                          prefixIcon: Icons.person,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _generation,
                          decoration: _dropdownDecoration(
                            label: 'Thế hệ (*)',
                            icon: Icons.account_tree_outlined,
                          ),
                          dropdownColor: secondaryBg,
                          style: TextStyle(color: primaryTextColor),
                          items: _generationOptions
                              .map(
                                (generation) => DropdownMenuItem<int>(
                                  value: generation.id,
                                  child: Text(
                                    generation.title?.isNotEmpty == true
                                        ? '${generation.name} — ${generation.title}'
                                        : generation.name,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _generation = value);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: _dropdownDecoration(
                            label: 'Giới tính',
                            icon: Icons.wc,
                          ),
                          dropdownColor: secondaryBg,
                          style: TextStyle(color: primaryTextColor),
                          hint: Text('Chưa xác định',
                              style: TextStyle(color: secondaryTextColor)),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Nam')),
                            DropdownMenuItem(
                                value: 'female', child: Text('Nữ')),
                            DropdownMenuItem(
                                value: 'other', child: Text('Khác')),
                          ],
                          onChanged: _isSaving
                              ? null
                              : (value) => setState(() => _gender = value),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _dateOfBirthController,
                          label: 'Ngày sinh',
                          hint: 'YYYY-MM-DD',
                          prefixIcon: Icons.calendar_today,
                          validator: _validateDateOfBirth,
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _roleController,
                          label: 'Vai trò / danh xưng',
                          hint: 'Ví dụ: Trưởng tộc, con trưởng',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _memberSelector(
                          label: 'Cha',
                          icon: Icons.man,
                          value: _fatherId,
                          members: _parentOptions,
                          onChanged: (value) =>
                              setState(() => _fatherId = value),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _memberSelector(
                          label: 'Mẹ',
                          icon: Icons.woman,
                          value: _motherId,
                          members: _parentOptions,
                          onChanged: (value) =>
                              setState(() => _motherId = value),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              'Thông tin bổ sung',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: [
                              _memberSelector(
                                label: 'Vợ / chồng',
                                icon: Icons.favorite_outline,
                                value: _spouseId,
                                members: _spouseOptions,
                                onChanged: (value) =>
                                    setState(() => _spouseId = value),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.child_care_outlined),
                                title: Text(
                                  'Con cái (${_childIds.length})',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                                subtitle: _childIds.isEmpty
                                    ? null
                                    : Text(
                                        _childIds
                                            .map(_memberNameForId)
                                            .join(', '),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                trailing: TextButton(
                                  onPressed: _isSaving ? null : _editChildren,
                                  child: const Text('Chỉnh sửa'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.people_alt_outlined),
                                title: Text(
                                  'Quan hệ ngang',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                                trailing: TextButton.icon(
                                  onPressed:
                                      _isSaving ? null : _addHorizontalRelation,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Thêm'),
                                ),
                              ),
                              if (_horizontalRelations.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _horizontalRelations
                                        .map(
                                          (relation) => InputChip(
                                            label: Text(
                                              '${_memberNameForId(relation.memberId)} · ${relation.relationType}',
                                            ),
                                            onDeleted: _isSaving
                                                ? null
                                                : () =>
                                                    _removeHorizontalRelation(
                                                      relation,
                                                    ),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _phoneNumberController,
                                label: 'Số điện thoại',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _addressController,
                                label: 'Địa chỉ',
                                prefixIcon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _facebookUrlController,
                                label: 'Facebook URL',
                                prefixIcon: Icons.facebook,
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _instagramUrlController,
                                label: 'Instagram URL',
                                prefixIcon: Icons.camera_alt_outlined,
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _avatarUrlController,
                                label: 'Avatar URL',
                                prefixIcon: Icons.image_outlined,
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _biographyController,
                                label: 'Tiểu sử',
                                prefixIcon: Icons.notes_outlined,
                              ),
                            ],
                          ),
                        ),
                        if (_submitError != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _submitError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CyberButton(
                            text: widget.initialMember == null
                                ? 'LƯU THÀNH VIÊN'
                                : 'CẬP NHẬT',
                            icon: Icons.save,
                            primaryColor: accentColor,
                            height: 50,
                            isLoading: _isSaving,
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberSelector({
    required String label,
    required IconData icon,
    required int? value,
    required List<FamilyMember> members,
    required ValueChanged<int?> onChanged,
    required bool isDark,
  }) {
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: _dropdownDecoration(label: label, icon: icon),
      dropdownColor:
          isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight,
      style: TextStyle(color: primaryTextColor),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Chưa chọn'),
        ),
        ...members.map(
          (member) => DropdownMenuItem<int?>(
            value: member.id,
            child: Text(member.fullName),
          ),
        ),
      ],
      onChanged: _isSaving ? null : onChanged,
    );
  }

  String _memberNameForId(int id) {
    for (final member in widget.availableMembers) {
      if (member.id == id) return member.fullName;
    }
    return 'Thành viên #$id';
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.accentGold, size: 20),
      filled: true,
      fillColor: AppColors.surfaceBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
      ),
    );
  }
}

String? _emptyToNull(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}
