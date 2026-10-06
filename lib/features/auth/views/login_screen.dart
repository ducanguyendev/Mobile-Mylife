import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/l10n/app_strings.dart';
import '../../../shared/services/token_storage_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../services/google_auth_service.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/google_sign_in_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final tokenStorage = ref.read(tokenStorageServiceProvider);
    final email = await tokenStorage.getRememberedEmail();
    if (email != null && mounted) {
      setState(() {
        _rememberMe = true;
        _emailController.text = email;
      });
    } else if (mounted) {
      setState(() {
        _rememberMe = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _startErrorTimer() {
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        ref.read(authStateProvider.notifier).clearError();
      }
    });
  }

  void _handleLogin(String lang) async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
            _rememberMe,
          );

      if (success && mounted) {
        TextInput.finishAutofillContext(shouldSave: true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(AppStrings.get('login_success_msg', lang)),
          ),
        );
      }
    }
  }

  void _handleGoogleLogin(String lang) async {
    final nav = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    setState(() => _isGoogleLoading = true);

    String? googleIdToken;

    try {
      googleIdToken = await GoogleAuthService.signIn();
    } catch (error, stackTrace) {
      debugPrint('Google Sign-In SDK failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        scaffold.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              lang == 'vi'
                  ? 'Không thể kết nối với Google. Vui lòng thử lại.'
                  : 'Unable to connect to Google. Please try again.',
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    if (googleIdToken != null && googleIdToken.trim().isNotEmpty) {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.loginWithGoogle(googleIdToken);

      if (mounted) {
        setState(() => _isGoogleLoading = false);
        if (success) {
          nav.pop();
          scaffold.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                lang == 'vi'
                    ? 'Đăng nhập Google thành công!'
                    : 'Signed in with Google successfully!',
              ),
            ),
          );
        } else {
          final error = ref.read(authStateProvider).errorMessage ??
              (lang == 'vi'
                  ? 'Đăng nhập Google thất bại'
                  : 'Google sign-in failed');
          scaffold.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(error),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _startErrorTimer();
      }
    });

    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

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

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: AutofillGroup(
              child: AuthCardContainer(
                formKey: _formKey,
                headerIcon: Icons.verified_user_outlined,
                title: AppStrings.get('login_title', lang),
                subtitle: AppStrings.get('login_subtitle', lang),
                errorBanner: authState.errorMessage != null
                    ? AuthErrorBanner(errorMessage: authState.errorMessage!)
                    : null,
                children: [
                  // Email Label
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

                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    validator: Validators.validateEmail,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        size: 19,
                        color: textSecondary,
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
                  const SizedBox(height: 18),

                  // Password Label
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

                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    validator: Validators.validatePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 19,
                        color: textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 19,
                          color: textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
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
                  const SizedBox(height: 12),

                  // Remember Me Checkbox
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final newVal = !_rememberMe;
                      setState(() => _rememberMe = newVal);
                      if (!newVal) {
                        await ref
                            .read(tokenStorageServiceProvider)
                            .clearRememberedEmail();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: accentColor,
                            checkColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            side: BorderSide(color: borderColor, width: 1.2),
                            onChanged: (val) async {
                              final newVal = val ?? false;
                              setState(() => _rememberMe = newVal);
                              if (!newVal) {
                                await ref
                                    .read(tokenStorageServiceProvider)
                                    .clearRememberedEmail();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get('remember_password', lang),
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : () => _handleLogin(lang),
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
                              AppStrings.get('login_title', lang),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: btnTextColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider "hoặc đăng nhập bằng"
                  AuthDivider(text: AppStrings.get('or_login_with', lang)),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  GoogleSignInButton(
                    isLoading: _isGoogleLoading,
                    onPressed: _isGoogleLoading ||
                            authState.status == AuthStatus.loading
                        ? null
                        : () => _handleGoogleLogin(lang),
                    label: AppStrings.get('login_with_google', lang),
                    loadingLabel: lang == 'vi'
                        ? 'Đang kết nối Google...'
                        : 'Connecting to Google...',
                  ),
                  const SizedBox(height: 20),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.get('no_account_prompt', lang),
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          AppStrings.get('register_now', lang),
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
      ),
    );
  }
}
