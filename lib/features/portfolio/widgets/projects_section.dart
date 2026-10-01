import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/cyber_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../models/portfolio_models.dart';
import '../views/project_detail_sheet.dart';

class ProjectsSection extends ConsumerWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final projects = getPortfolioProjects(currentLang);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_special, color: accentColor),
              const SizedBox(width: 8),
              Text(
                lang.tr('projects_title'),
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
            lang.tr('projects_subtitle'),
            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Divider(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (_, index) {
              final project = projects[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceBg.withValues(alpha: 0.5) : AppColors.cardBgLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Thumbnail
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.asset(
                        project.mainImage,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight,
                          child: const Icon(Icons.image_not_supported, size: 40, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: project.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),

                          // Title
                          Text(
                            project.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTextColor),
                          ),
                          const SizedBox(height: 6),

                          // Description
                          Text(
                            project.description,
                            style: TextStyle(color: secondaryTextColor, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 12),

                          // View Details Button
                          CyberButton(
                            text: lang.tr('btn_view_screens'),
                            icon: Icons.open_in_new,
                            primaryColor: accentColor,
                            height: 42,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ProjectDetailSheet(project: project),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
