import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../models/portfolio_models.dart';
import '../widgets/screen_preview_block.dart';

class ProjectDetailSheet extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailSheet({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailSheet> createState() => _ProjectDetailSheetState();
}

class _ProjectDetailSheetState extends ConsumerState<ProjectDetailSheet> {
  late String _activeTabKey;

  @override
  void initState() {
    super.initState();
    _activeTabKey = widget.project.tabs.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryBg = isDark ? AppColors.primaryBg : AppColors.primaryBgLight;
    final secondaryBg =
        isDark ? AppColors.secondaryBg : AppColors.secondaryBgLight;
    final surfaceBg = isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight;
    final borderSubtle =
        isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    final project = widget.project;
    final activeScreen =
        project.screens[_activeTabKey] ?? project.screens.values.first;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: primaryBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: secondaryBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: borderSubtle)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.modalTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project.techStack,
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tabs Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark
                ? AppColors.cardBg.withValues(alpha: 0.5)
                : AppColors.surfaceBgLight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: project.tabs.entries.map((entry) {
                  final isSelected = _activeTabKey == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      selectedColor: accentColor,
                      backgroundColor: surfaceBg,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : secondaryTextColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? accentColor : borderSubtle,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _activeTabKey = entry.key);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Active Screen Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenPreviewBlock(
                    tag: activeScreen.tag,
                    title: activeScreen.title,
                    desc: activeScreen.desc,
                    desc2: activeScreen.desc2.isNotEmpty
                        ? activeScreen.desc2
                        : null,
                    imagePaths: [activeScreen.imagePath],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            color: secondaryBg,
            alignment: Alignment.center,
            child: Text(
              project.footer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
