import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Row(
      children: [
        Expanded(child: Divider(color: borderColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: borderColor, thickness: 1)),
      ],
    );
  }
}
