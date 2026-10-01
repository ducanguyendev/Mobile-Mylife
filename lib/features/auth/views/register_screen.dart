import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/l10n/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/utils/date_formatter.dart';
import '../models/auth_requests.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_error_banner.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = 'Nam';
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _localErrorMessage;
  String? _successMessage;
  Timer? _errorTimer;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _successTimer?.cancel();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _localErrorMessage = message;
    });
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _localErrorMessage = null;
        });
        ref.read(authStateProvider.notifier).clearError();
      }
    });
  }

  Future<void> _pickDate(bool isDark) async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 20, now.month, now.day);
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
                    surface: AppColors.secondaryBg,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.accentGoldLightMode,
                    onPrimary: Colors.white,
                    surface: AppColors.primaryBgLight,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormatter.formatVN(picked);
      });
    }
  }

  // Password Strength Calculation (0 - 4)
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score <= 1) return 1;
    if (score <= 2) return 2;
    if (score <= 4) return 3;
    return 4;
  }

  void _handleRegister(String lang) async {
    // 1. Full name validation
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      _showError(lang == 'vi'
          ? 'Vui lòng nhập họ và tên.'
          : 'Please enter your full name.');
      return;
    }
    if (fullName.length < 2 || fullName.length > 50) {
      _showError(lang == 'vi'
          ? 'Họ và tên phải từ 2 đến 50 ký tự.'
          : 'Full name must be 2-50 characters.');
      return;
    }

    // 2. Phone validation
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError(lang == 'vi'
          ? 'Vui lòng nhập số điện thoại.'
          : 'Please enter your phone number.');
      return;
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      _showError(lang == 'vi'
          ? 'Số điện thoại không hợp lệ (Phải gồm 10 số bắt đầu bằng 03, 05, 07, 08, 09).'
          : 'Invalid phone number format.');
      return;
    }

    // 3. Date of birth validation
    if (_selectedDate == null) {
      _showError(lang == 'vi'
          ? 'Vui lòng chọn ngày sinh.'
          : 'Please select your date of birth.');
      return;
    }

    // 4. Email validation
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showError(lang == 'vi'
          ? 'Vui lòng nhập địa chỉ email.'
          : 'Please enter your email.');
      return;
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      _showError(lang == 'vi'
          ? 'Địa chỉ email không đúng định dạng.'
          : 'Invalid email format.');
      return;
    }

    // 5. Password validation
    final password = _passwordController.text;
    if (password.length < 8 || password.length > 72) {
      _showError(lang == 'vi'
          ? 'Mật khẩu phải có độ dài từ 8 đến 72 ký tự.'
          : 'Password must be between 8 and 72 characters.');
      return;
    }

    // 6. Confirm password validation
    final confirmPassword = _confirmPasswordController.text;
    if (password != confirmPassword) {
      _showError(lang == 'vi'
          ? 'Mật khẩu xác nhận chưa trùng khớp.'
          : 'Passwords do not match.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      final req = RegisterRequest(
        fullName: fullName,
        phoneNumber: phone,
        gender: _selectedGender,
        dateOfBirth: DateFormatter.formatIso(_selectedDate!),
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final success = await ref.read(authStateProvider.notifier).register(req);
      if (success && mounted) {
        setState(() {
          _successMessage = AppStrings.get('register_success_msg', lang);
          _localErrorMessage = null;
        });

        _successTimer = Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _showError(next.errorMessage!);
      }
    });

    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    // Colors
    final inputBg = isDark ? AppColors.primaryBg : AppColors.primaryBgLight;
    final borderColor =
        isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final accentColor =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final btnTextColor = isDark ? AppColors.primaryBg : Colors.white;

    final displayedError = _localErrorMessage ?? authState.errorMessage;
    final passStrength = _calculatePasswordStrength(_passwordController.text);
    final isMatching = _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: AuthCardContainer(
              formKey: _formKey,
              headerIcon: Icons.verified_user_outlined,
              title: AppStrings.get('register_title', lang),
              subtitle: AppStrings.get('register_subtitle', lang),
              errorBanner: displayedError != null
                  ? AuthErrorBanner(errorMessage: displayedError)
                  : null,
              children: [
                // Success Banner
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: _successMessage != null
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: AppColors.success, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Full Name
                Text(
                  AppStrings.get('lbl_fullname_upper', lang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null,
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        size: 19, color: textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number
                Text(
                  AppStrings.get('lbl_phone_upper', lang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null,
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(Icons.phone_outlined,
                        size: 19, color: textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Row: Date of birth & Gender
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date of birth
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('lbl_dob_upper', lang),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _pickDate(isDark),
                            style: TextStyle(color: textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: null,
                              filled: true,
                              fillColor: inputBg,
                              prefixIcon: Icon(Icons.calendar_today_outlined,
                                  size: 18, color: textSecondary),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: borderColor, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: borderColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Gender Pill Control
                    Expanded(
                      flex: 13,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('lbl_gender_upper', lang),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Row(
                              children: [
                                _genderOption(
                                    'Nam',
                                    AppStrings.get('gender_male', lang),
                                    accentColor,
                                    isDark),
                                _genderOption(
                                    'Nữ',
                                    AppStrings.get('gender_female', lang),
                                    accentColor,
                                    isDark),
                                _genderOption(
                                    'Khác',
                                    AppStrings.get('gender_other', lang),
                                    accentColor,
                                    isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                Text(
                  AppStrings.get('lbl_email_upper', lang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null,
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        size: 19, color: textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Text(
                  AppStrings.get('lbl_password_upper', lang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null,
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(Icons.lock_outline_rounded,
                        size: 19, color: textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),

                // Password Strength Meter
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3, 4].map((bar) {
                      final isActive = passStrength >= bar;
                      Color barColor = const Color(0xFFEF4444);
                      if (passStrength == 2) barColor = const Color(0xFFF59E0B);
                      if (passStrength == 3) barColor = const Color(0xFF3B82F6);
                      if (passStrength == 4) barColor = const Color(0xFF10B981);

                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isActive ? barColor : borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),

                // Confirm Password
                Text(
                  AppStrings.get('lbl_confirm_password_upper', lang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null,
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(Icons.lock_reset_outlined,
                        size: 19, color: textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: textSecondary,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _confirmPasswordController.text.isNotEmpty
                            ? (isMatching
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            : borderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _confirmPasswordController.text.isNotEmpty
                            ? (isMatching
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            : borderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _confirmPasswordController.text.isNotEmpty
                            ? (isMatching
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            : accentColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Match indicator text
                if (_confirmPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    isMatching
                        ? (lang == 'vi'
                            ? '✓ Mật khẩu khớp'
                            : '✓ Passwords match')
                        : (lang == 'vi'
                            ? '✗ Mật khẩu chưa khớp'
                            : '✗ Passwords do not match'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isMatching
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Register Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () => _handleRegister(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: btnTextColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authState.status == AuthStatus.loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(btnTextColor),
                            ),
                          )
                        : Text(
                            AppStrings.get('register_btn', lang),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: btnTextColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('already_have_account', lang),
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        AppStrings.get('login_now', lang),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
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

  Widget _genderOption(String key, String label, Color accent, bool isDark) {
    final isSelected = _selectedGender == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = key),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
