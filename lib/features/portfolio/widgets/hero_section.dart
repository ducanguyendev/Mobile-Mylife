import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GlassContainer(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Circular Character Avatar matching Web
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar_duka.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 60,
                  backgroundColor: isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight,
                  child: Icon(Icons.person, size: 50, color: accentColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            lang.tr('hero_greet'),
            style: TextStyle(color: secondaryTextColor, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 4),

          Text(
            lang.tr('hero_name'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            lang.tr('hero_title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            lang.tr('hero_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Scroll to contact or perform action
              },
              icon: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.black : Colors.white),
              label: Text(
                lang.tr('home.btnContact') ?? 'Contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? accentColor : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Horizontal Stats Bar matching Web Theme
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceBg.withValues(alpha: 0.6) : AppColors.cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(lang.tr('stats_exp_val'), style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        lang.tr('stats_exp_lbl'),
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      Text(lang.tr('stats_proj_val'), style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        lang.tr('stats_proj_lbl'),
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      Text(lang.tr('stats_clients_val'), style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        lang.tr('stats_clients_lbl'),
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
