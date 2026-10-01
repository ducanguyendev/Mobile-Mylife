import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/views/login_screen.dart';

class UnauthenticatedProfileCard extends ConsumerWidget {
  const UnauthenticatedProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final cardBg = isDark ? const Color(0xFF14131C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentGold = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: accentGold),
              const SizedBox(height: 16),
              Text(
                lang == 'vi' ? 'BẠN CHƯA ĐĂNG NHẬP' : 'NOT SIGNED IN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'vi'
                    ? 'Đăng nhập để xem thông tin hồ sơ và bảo mật'
                    : 'Sign in to view your profile and account security',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    lang == 'vi' ? 'ĐĂNG NHẬP NGAY' : 'SIGN IN NOW',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
