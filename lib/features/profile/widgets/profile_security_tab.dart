import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../admin/views/admin_dashboard_screen.dart';
import '../../auth/models/user_model.dart';

class ProfileSecurityTab extends ConsumerWidget {
  final UserModel user;
  final String lang;
  final bool isDark;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const ProfileSecurityTab({
    super.key,
    required this.user,
    required this.lang,
    required this.isDark,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = isDark ? const Color(0xFF14131C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentGold = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return Column(
      children: [
        // Admin Panel Access if user is Admin
        if (user.isAdmin) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFEF4444), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'vi' ? 'Bảng Quản Trị Hệ Thống' : 'Admin Control Panel',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang == 'vi'
                            ? 'Quản lý tài khoản & thống kê người dùng'
                            : 'Manage users and platform analytics',
                        style: TextStyle(color: textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFEF4444)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Security Settings Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_reset_rounded, size: 18, color: accentGold),
                  const SizedBox(width: 8),
                  Text(
                    lang == 'vi' ? 'BẢO MẬT TÀI KHOẢN' : 'ACCOUNT SECURITY',
                    style: TextStyle(
                      color: accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Divider(color: cardBorder, height: 22),

              // Change Password Button
              InkWell(
                onTap: onChangePassword,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.key_rounded, size: 20, color: accentGold),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'vi' ? 'Đổi mật khẩu tài khoản' : 'Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == 'vi'
                                  ? 'Cập nhật mật khẩu định kỳ để bảo vệ tài khoản'
                                  : 'Update your password regularly for security',
                              style: TextStyle(fontSize: 11.5, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Language Switch Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1C2E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.language_rounded, size: 20, color: textPrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        lang == 'vi' ? 'Ngôn ngữ hiển thị' : 'Display Language',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: textPrimary),
                      ),
                    ),
                    // Flag switchers
                    GestureDetector(
                      onTap: () => ref.read(languageProvider.notifier).setLanguage('vi'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lang == 'vi' ? accentGold.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: lang == 'vi' ? accentGold : cardBorder),
                        ),
                        child: const Text('🇻🇳 VI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => ref.read(languageProvider.notifier).setLanguage('en'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lang == 'en' ? accentGold.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: lang == 'en' ? accentGold : cardBorder),
                        ),
                        child: const Text('🇬🇧 EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sign Out Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onLogout,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, size: 19),
                const SizedBox(width: 10),
                Text(
                  lang == 'vi' ? 'ĐĂNG XUẤT TÀI KHOẢN' : 'SIGN OUT OF ACCOUNT',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
