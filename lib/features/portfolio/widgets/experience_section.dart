import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class ExperienceSection extends ConsumerWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final experiences = [
      {
        'role': lang.tr('exp1_role'),
        'company': lang.tr('exp1_company'),
        'duration': lang.tr('exp1_duration'),
        'desc': lang.tr('exp1_desc'),
      },
      {
        'role': lang.tr('exp2_role'),
        'company': lang.tr('exp2_company'),
        'duration': lang.tr('exp2_duration'),
        'desc': lang.tr('exp2_desc'),
      },
      {
        'role': lang.tr('exp3_role'),
        'company': lang.tr('exp3_company'),
        'duration': lang.tr('exp3_duration'),
        'desc': lang.tr('exp3_desc'),
      },
    ];

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_history, color: accentColor),
              const SizedBox(width: 8),
              Text(
                lang.tr('exp_title'),
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
            lang.tr('exp_subtitle'),
            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Divider(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 12.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: experiences.length,
              itemBuilder: (_, idx) {
                final exp = experiences[idx];
                final isLast = idx == experiences.length - 1;
                
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline line and dot
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, width: 2),
                            ),
                            child: Icon(Icons.work_outline, size: 16, color: accentColor),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0, top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp['duration']!,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exp['role']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exp['company']!,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exp['desc']!,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
