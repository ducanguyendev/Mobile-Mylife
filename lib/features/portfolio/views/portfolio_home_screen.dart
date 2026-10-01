import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/app_menu_drawer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/views/profile_screen.dart';
import '../widgets/about_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/skills_section.dart';

class PortfolioHomeScreen extends ConsumerWidget {
  const PortfolioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      endDrawer: const AppMenuDrawer(),
      appBar: AppBar(
        title: Text(
          'MYLIFE PORTFOLIO',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        actions: [
          // Khi đã đăng nhập: Hiển thị avatar tròn clickable mở màn hình Hồ sơ
          if (authState.isAuthenticated && user != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    width: 36,
                    height: 36,
                    color: accentColor,
                    child: user.fullAvatarUrl != null && user.fullAvatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.fullAvatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Text(
                                user.initials,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            )
          else ...[
            // Khi chưa đăng nhập: Hiển thị icon 3 gạch (Menu Drawer)
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: accentColor, size: 26),
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Section
            HeroSection(),
            SizedBox(height: 24),

            // 2. About Me Section
            AboutSection(),
            SizedBox(height: 24),

            // 3. Skills Section
            SkillsSection(),
            SizedBox(height: 24),

            // 4. Featured Projects Section
            ProjectsSection(),
            SizedBox(height: 24),

            // 5. Experience Timeline Section
            ExperienceSection(),
            SizedBox(height: 24),

            // 6. Contact Form Section
            ContactSection(),
            SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
