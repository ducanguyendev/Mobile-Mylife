import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class AuthCardContainer extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final IconData headerIcon;
  final String title;
  final String subtitle;
  final Widget? errorBanner;
  final List<Widget> children;
  final VoidCallback? onClose;

  const AuthCardContainer({
    super.key,
    required this.formKey,
    required this.headerIcon,
    required this.title,
    required this.subtitle,
    this.errorBanner,
    required this.children,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.secondaryBg : AppColors.primaryBgLight;
    final borderColor = isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Center Icon and Close 'X' button
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      headerIcon,
                      size: 28,
                      color: accentColor,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: textSecondary, size: 22),
                      splashRadius: 20,
                      onPressed: onClose ?? () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Error Banner (if any)
              if (errorBanner != null) ...[
                errorBanner!,
                const SizedBox(height: 16),
              ],

              // Form content
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
