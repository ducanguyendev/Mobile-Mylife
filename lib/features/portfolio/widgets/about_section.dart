import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin, color: accentColor),
              const SizedBox(width: 8),
              Text(
                lang.tr('about_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lang.tr('about_subtitle'),
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(
            color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight,
            height: 20,
          ),

          // Full-body character image matching Web (Aspect Ratio 2/3 - completely visible from head to toe)
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.asset(
                    'assets/images/body_duka.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            lang.tr('about_p1'),
            style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            lang.tr('about_p2'),
            style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
