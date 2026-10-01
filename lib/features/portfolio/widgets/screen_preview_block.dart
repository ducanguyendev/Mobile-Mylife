import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';

class ScreenPreviewBlock extends ConsumerWidget {
  final String tag;
  final String title;
  final String desc;
  final String? desc2;
  final List<String> imagePaths;
  final bool reverse;

  const ScreenPreviewBlock({
    super.key,
    required this.tag,
    required this.title,
    required this.desc,
    this.desc2,
    required this.imagePaths,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor =
        isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final surfaceBg = isDark ? AppColors.surfaceBg : AppColors.surfaceBgLight;
    final borderSubtle =
        isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accentColor),
          ),
          child: Text(
            tag.toUpperCase(),
            style: TextStyle(
                color: accentColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w300),
        ),
        if (desc2 != null && desc2!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            desc2!,
            style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w300),
          ),
        ],
      ],
    );

    final imagesColumn = Column(
      children: imagePaths.map((path) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryBg : AppColors.primaryBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Browser-like Window Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.primaryBg : AppColors.primaryBgLight,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  border: Border(bottom: BorderSide(color: borderSubtle)),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.7),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.7),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.7),
                            shape: BoxShape.circle)),
                  ],
                ),
              ),
              // Image Content
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(11)),
                child: Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: surfaceBg,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined,
                        size: 48, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reverse
            ? [imagesColumn, const SizedBox(height: 24), textColumn]
            : [textColumn, const SizedBox(height: 24), imagesColumn],
      ),
    );
  }
}
