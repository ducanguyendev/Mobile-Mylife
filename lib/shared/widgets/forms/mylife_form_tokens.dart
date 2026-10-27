import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Mobile equivalents of the web --field-* variables in Frontend-MyLife/src/index.css.
class MyLifeFormTokens {
  const MyLifeFormTokens({
    required this.fieldBackground,
    required this.fieldBorder,
    required this.fieldText,
    required this.fieldLabel,
    required this.fieldPlaceholder,
    required this.fieldFocusBorder,
    required this.fieldFocusRing,
    required this.fieldError,
    required this.fieldDisabledBackground,
  });

  final Color fieldBackground;
  final Color fieldBorder;
  final Color fieldText;
  final Color fieldLabel;
  final Color fieldPlaceholder;
  final Color fieldFocusBorder;
  final Color fieldFocusRing;
  final Color fieldError;
  final Color fieldDisabledBackground;

  factory MyLifeFormTokens.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MyLifeFormTokens(
      fieldBackground: isDark
          ? AppColors.fieldBackgroundDark
          : AppColors.fieldBackgroundLight,
      fieldBorder:
          isDark ? AppColors.fieldBorderDark : AppColors.fieldBorderLight,
      fieldText: isDark ? AppColors.fieldTextDark : AppColors.fieldTextLight,
      fieldLabel: isDark ? AppColors.fieldLabelDark : AppColors.fieldLabelLight,
      fieldPlaceholder: isDark
          ? AppColors.fieldPlaceholderDark
          : AppColors.fieldPlaceholderLight,
      fieldFocusBorder: isDark
          ? AppColors.fieldFocusBorderDark
          : AppColors.fieldFocusBorderLight,
      fieldFocusRing:
          isDark ? AppColors.fieldFocusRingDark : AppColors.fieldFocusRingLight,
      fieldError: AppColors.error,
      fieldDisabledBackground: isDark
          ? AppColors.fieldDisabledBackgroundDark
          : AppColors.fieldDisabledBackgroundLight,
    );
  }
}
