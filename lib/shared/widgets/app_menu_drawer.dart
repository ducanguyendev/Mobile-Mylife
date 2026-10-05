import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../../features/admin/views/admin_dashboard_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/profile/widgets/change_password_dialog.dart';
import '../l10n/app_language_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_provider.dart';

class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLang = ref.watch(languageProvider);
    final langNotifier = ref.read(languageProvider.notifier);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final apiBaseUrl = ref.watch(apiBaseUrlProvider).valueOrNull ??
        ref.watch(dioClientProvider).options.baseUrl;
    final avatarUrl = user?.avatarUrlForBase(apiBaseUrl);
    final isVi = currentLang == 'vi';

    final bgDrawer = isDark ? const Color(0xFF111111) : const Color(0xFFFFFFFF);
    final cardSurface =
        isDark ? const Color(0xFF181818) : const Color(0xFFF7F7F8);
    final cardBorder =
        isDark ? const Color(0xFF242424) : const Color(0xFFE8E8EC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textSecondary =
        isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6E6E73);
    final accentGold =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return Drawer(
      backgroundColor: bgDrawer,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ==============================================================
            // 1. TOP HEADER (BRANDING & CLOSE BUTTON)
            // ==============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cardBorder, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentGold.withValues(alpha: 0.25),
                          accentGold.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentGold.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MYLIFE MENU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Circular close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBorder),
                        ),
                        child: Icon(Icons.close_rounded,
                            color: textSecondary, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==============================================================
            // 2. SCROLLABLE MENU SECTIONS
            // ==============================================================
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                children: [
                  // ----------------------------------------------------------
                  // SECTION A: THEME SWITCHER
                  // ----------------------------------------------------------
                  _buildSectionHeader(
                    icon: Icons.palette_outlined,
                    title: langNotifier.tr('theme_header'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF201B10)
                                : const Color(0xFFFFF7E6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: accentGold,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isDark
                                ? langNotifier.tr('theme_dark')
                                : langNotifier.tr('theme_light'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: isDark,
                          activeTrackColor: accentGold,
                          activeThumbColor:
                              isDark ? const Color(0xFF111111) : Colors.white,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ----------------------------------------------------------
                  // SECTION B: LANGUAGE SWITCHER (FLAGS ONLY WITH SLEEK CARDS)
                  // ----------------------------------------------------------
                  _buildSectionHeader(
                    icon: Icons.translate_rounded,
                    title: langNotifier.tr('lang_header'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Vietnam Flag
                      Expanded(
                        child: InkWell(
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage('vi'),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isVi
                                  ? accentGold.withValues(alpha: 0.12)
                                  : cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isVi ? accentGold : cardBorder,
                                width: isVi ? 2.0 : 1.0,
                              ),
                              boxShadow: isVi
                                  ? [
                                      BoxShadow(
                                        color:
                                            accentGold.withValues(alpha: 0.18),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  '🇻🇳',
                                  style: TextStyle(fontSize: 32),
                                ),
                                if (isVi)
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: accentGold,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // USA Flag
                      Expanded(
                        child: InkWell(
                          onTap: () => ref
                              .read(languageProvider.notifier)
                              .setLanguage('en'),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isVi
                                  ? accentGold.withValues(alpha: 0.12)
                                  : cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !isVi ? accentGold : cardBorder,
                                width: !isVi ? 2.0 : 1.0,
                              ),
                              boxShadow: !isVi
                                  ? [
                                      BoxShadow(
                                        color:
                                            accentGold.withValues(alpha: 0.18),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  '🇺🇸',
                                  style: TextStyle(fontSize: 32),
                                ),
                                if (!isVi)
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: accentGold,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ----------------------------------------------------------
                  // SECTION C: ACCOUNT & LOGIN (NO REGISTER BUTTON)
                  // ----------------------------------------------------------
                  _buildSectionHeader(
                    icon: Icons.manage_accounts_outlined,
                    title: langNotifier.tr('account_header'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  if (!authState.isAuthenticated || user == null) ...[
                    // Nút Đăng Nhập Sang Trọng (Duy nhất, gọn gàng, không chữ thừa)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          foregroundColor:
                              isDark ? const Color(0xFF0A0A0A) : Colors.white,
                          elevation: 3,
                          shadowColor: accentGold.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              size: 19,
                              color: isDark
                                  ? const Color(0xFF0A0A0A)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              langNotifier.tr('btn_login'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: isDark
                                    ? const Color(0xFF0A0A0A)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Chế độ đã đăng nhập: Thẻ thông tin cá nhân & Các chức năng
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: accentGold, width: 1.5),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: accentGold,
                                  backgroundImage:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                  child: avatarUrl == null || avatarUrl.isEmpty
                                      ? Text(
                                          user.email.trim().length >= 2
                                              ? user.email
                                                  .trim()
                                                  .substring(0, 2)
                                                  .toUpperCase()
                                              : (user.email.trim().isNotEmpty
                                                  ? user.email
                                                      .trim()
                                                      .toUpperCase()
                                                  : 'U'),
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF0A0A0A)
                                                : Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            accentGold.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: accentGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          // Hồ sơ cá nhân
                          _buildMenuActionTile(
                            icon: Icons.person_outline_rounded,
                            title: langNotifier.tr('menu_profile'),
                            isDark: isDark,
                            accentColor: accentGold,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()),
                              );
                            },
                          ),
                          // Quản trị hệ thống (nếu là Admin)
                          if (authState.isAdmin) ...[
                            _buildMenuActionTile(
                              icon: Icons.admin_panel_settings_outlined,
                              title: langNotifier.tr('menu_admin'),
                              isDark: isDark,
                              accentColor: accentGold,
                              iconColor: AppColors.warning,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminDashboardScreen()),
                                );
                              },
                            ),
                          ],
                          // Đổi mật khẩu
                          _buildMenuActionTile(
                            icon: Icons.lock_reset_rounded,
                            title: langNotifier.tr('menu_change_pw'),
                            isDark: isDark,
                            accentColor: accentGold,
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => const ChangePasswordDialog(),
                              );
                            },
                          ),
                          // Đăng xuất
                          _buildMenuActionTile(
                            icon: Icons.logout_rounded,
                            title: langNotifier.tr('menu_logout'),
                            isDark: isDark,
                            accentColor: accentGold,
                            iconColor: AppColors.error,
                            textColor: AppColors.error,
                            onTap: () async {
                              Navigator.pop(context);
                              await ref
                                  .read(authStateProvider.notifier)
                                  .logout();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: accentGold,
                                  content: Text(
                                    langNotifier.tr('logged_out_msg'),
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF0A0A0A)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ==============================================================
            // 3. FOOTER SIGNATURE
            // ==============================================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'MYLIFE Portfolio • v1.0',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuActionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color accentColor,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (iconColor ?? accentColor).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? accentColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor ??
              (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
      ),
      onTap: onTap,
    );
  }
}
