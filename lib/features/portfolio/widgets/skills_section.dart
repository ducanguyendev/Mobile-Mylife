import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/portfolio_models.dart';

class SkillsSection extends ConsumerWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final skills = [
      CircularSkill(name: 'C# / C++', level: 95, label: 'C#', color: '#e5c158'),
      CircularSkill(name: 'Node.js / Go', level: 90, label: 'Go', color: '#e5c158'),
      CircularSkill(name: 'Unity / Unreal', level: 90, label: 'Un', color: '#e5c158'),
      CircularSkill(name: 'SQL / NoSQL', level: 85, label: 'Db', color: '#e5c158'),
      CircularSkill(name: 'Docker / Git', level: 80, label: 'Dk', color: '#e5c158'),
    ];

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: accentColor),
              const SizedBox(width: 8),
              Text(
                lang.tr('skills_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          Divider(
            color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight,
            height: 20,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
            ),
            itemCount: skills.length,
            itemBuilder: (_, index) {
              final skill = skills[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 38,
                    lineWidth: 6,
                    percent: skill.level / 100,
                    center: CircleAvatar(
                      radius: 26,
                      backgroundColor: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
                      child: Text(
                        skill.label,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    progressColor: accentColor,
                    backgroundColor: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${skill.level}%',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    skill.name,
                    style: TextStyle(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
