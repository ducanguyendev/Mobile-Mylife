import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileDialog({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late String _gender;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user.fullName ?? widget.user.displayName,
    );
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );

    _gender = (_genderOptions.contains(widget.user.gender))
        ? widget.user.gender!
        : 'Nam';

    final dob = widget.user.dateOfBirth ?? '';
    _dobController = TextEditingController(text: dob);
    if (dob.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dob);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDark) async {
    final now = DateTime.now();
    final initial =
        _selectedDate ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 6, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.accentGold,
                    onPrimary: Colors.black,
                    surface: Color(0xFF181724),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.accentGoldLightMode,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSave(String lang) async {
    if (!_formKey.currentState!.validate()) return;

    if (_dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            lang == 'vi'
                ? 'Vui lòng chọn ngày sinh.'
                : 'Please select your date of birth.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authStateProvider.notifier).updateProfile(
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            gender: _gender,
            dateOfBirth: _dobController.text.trim(),
          );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                lang == 'vi'
                    ? 'Cập nhật thông tin cá nhân thành công!'
                    : 'Profile information updated successfully!',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                ref.read(authStateProvider).errorMessage ??
                    (lang == 'vi'
                        ? 'Cập nhật thất bại. Vui lòng kiểm tra lại thông tin.'
                        : 'Update failed. Please check your information.'),
              ),
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Profile save dialog failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              ApiError.message(
                error,
                fallback: lang == 'vi'
                    ? 'Lỗi kết nối máy chủ.'
                    : 'Server connection error.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    final bg = isDark ? const Color(0xFF14131C) : Colors.white;
    final border = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF1D1B28) : const Color(0xFFF8FAFC);
    final accentGold =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_note_rounded,
                          color: accentGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang == 'vi' ? 'CHỈNH SỬA THÔNG TIN' : 'EDIT PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(color: border),
                const SizedBox(height: 12),

                // 1. Họ và tên
                _buildLabel(lang == 'vi' ? 'Họ và tên *' : 'Full Name *',
                    textSecondary),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: _buildInputDecoration(
                    hint: lang == 'vi'
                        ? 'Nhập họ và tên...'
                        : 'Enter your full name...',
                    icon: Icons.person_outline_rounded,
                    inputBg: inputBg,
                    border: border,
                    accentColor: accentGold,
                    textSecondary: textSecondary,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return lang == 'vi'
                          ? 'Vui lòng nhập họ và tên.'
                          : 'Full name is required.';
                    }
                    if (val.trim().length < 2 || val.trim().length > 50) {
                      return lang == 'vi'
                          ? 'Họ và tên phải từ 2 đến 50 ký tự.'
                          : 'Must be 2-50 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 2. Số điện thoại
                _buildLabel(lang == 'vi' ? 'Số điện thoại *' : 'Phone Number *',
                    textSecondary),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: _buildInputDecoration(
                    hint: '03xxxxxxxx / 09xxxxxxxx',
                    icon: Icons.phone_android_rounded,
                    inputBg: inputBg,
                    border: border,
                    accentColor: accentGold,
                    textSecondary: textSecondary,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return lang == 'vi'
                          ? 'Vui lòng nhập số điện thoại.'
                          : 'Phone is required.';
                    }
                    if (!RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$')
                        .hasMatch(val.trim())) {
                      return lang == 'vi'
                          ? 'Số điện thoại 10 số, bắt đầu bằng 03, 05, 07, 08, 09.'
                          : 'Invalid VN phone number (10 digits).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 3. Giới tính
                _buildLabel(
                    lang == 'vi' ? 'Giới tính *' : 'Gender *', textSecondary),
                const SizedBox(height: 8),
                Row(
                  children: _genderOptions.map((opt) {
                    final isSelected = _gender == opt;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = opt),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentGold.withValues(alpha: 0.18)
                                : inputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? accentGold : border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? accentGold : textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // 4. Ngày sinh
                _buildLabel(lang == 'vi' ? 'Ngày sinh *' : 'Date of Birth *',
                    textSecondary),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _pickDate(isDark),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: _buildInputDecoration(
                    hint: 'YYYY-MM-DD',
                    icon: Icons.cake_outlined,
                    inputBg: inputBg,
                    border: border,
                    accentColor: accentGold,
                    textSecondary: textSecondary,
                    suffix: IconButton(
                      icon: Icon(Icons.calendar_month_rounded,
                          color: accentGold, size: 20),
                      onPressed: () => _pickDate(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions (Hủy & Lưu)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          lang == 'vi' ? 'HỦY' : 'CANCEL',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleSave(lang),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : Text(
                                lang == 'vi' ? 'LƯU THAY ĐỔI' : 'SAVE CHANGES',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required Color inputBg,
    required Color border,
    required Color accentColor,
    required Color textSecondary,
    Widget? suffix,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: inputBg,
      hintText: hint,
      hintStyle:
          TextStyle(color: textSecondary.withValues(alpha: 0.6), fontSize: 13),
      prefixIcon: Icon(icon, color: accentColor, size: 19),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
