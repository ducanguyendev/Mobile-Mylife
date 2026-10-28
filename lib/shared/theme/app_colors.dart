import 'package:flutter/material.dart';
import 'mylife_design_tokens.dart';

class AppColors {
  // Dark Backgrounds matching Web (index.css)
  static const Color primaryBg = MyLifeDesign.canvasDark;
  static const Color secondaryBg = MyLifeDesign.surfaceDark;
  static const Color cardBg = MyLifeDesign.surfaceDark;
  static const Color glassBg = Color(0xF2191B17);
  static const Color surfaceBg = MyLifeDesign.raisedDark;

  // Light Backgrounds matching Web (index.css)
  static const Color primaryBgLight = MyLifeDesign.canvasLight;
  static const Color secondaryBgLight = MyLifeDesign.surfaceLight;
  static const Color cardBgLight = MyLifeDesign.surfaceLight;
  static const Color surfaceBgLight = Color(0xFFEDE9DF);
  static const Color borderSubtleLight = Color(0xFFEAEAEA);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color accentGoldLightMode =
      Color(0xFFB58900); // Darker gold for light mode

  // Shared form field colors map to the web --field-* tokens in Frontend-MyLife/src/index.css.
  static const Color fieldBackgroundDark = Color(0xFF111111);
  static const Color fieldBackgroundLight = Color(0xFFFFFFFF);
  static const Color fieldBorderDark = Color(0xFF3F3F46);
  static const Color fieldBorderLight = Color(0xFFE6E6E2);
  static const Color fieldTextDark = Color(0xFFFFFFFF);
  static const Color fieldTextLight = Color(0xFF18181B);
  static const Color fieldLabelDark = Color(0xFFA1A1AA);
  static const Color fieldLabelLight = Color(0xFF666666);
  static const Color fieldPlaceholderDark = Color(0x9EA1A1AA);
  static const Color fieldPlaceholderLight = Color(0x9E666666);
  static const Color fieldFocusBorderDark = Color(0xFFA1A1AA);
  static const Color fieldFocusBorderLight = Color(0xFF71717A);
  static const Color fieldFocusRingDark = Color(0x29A1A1AA);
  static const Color fieldFocusRingLight = Color(0x2471717A);
  static const Color fieldDisabledBackgroundDark = Color(0xFF18181B);
  static const Color fieldDisabledBackgroundLight = Color(0xFFEFEFEC);

  // Web Luxury Gold Accents (index.css: --accent-color: #e5c158)
  static const Color accent = Color(0xFFE5C158);
  static const Color accentGold = Color(0xFFE5C158);
  static const Color accentGoldLight = Color(0xFFF3D98B);
  static const Color accentGoldDark = Color(0xFFCFA83C);
  static const Color accentHover = Color(0xFFCFA83C);

  // Aliases for compatibility
  static const Color accentCyan = Color(0xFFE5C158);
  static const Color accentCyanLight = Color(0xFFF3D98B);
  static const Color accentCyanDark = Color(0xFFCFA83C);
  static const Color accentBlue = Color(0xFFE5C158);
  static const Color accentPurple = Color(0xFFD4AF37);

  // Statuses
  static const Color success = Color(0xFF22C55E); // #22c55e
  static const Color warning = Color(0xFFF59E0B); // #f59e0b
  static const Color error = Color(0xFFEF4444); // #ef4444

  // Texts matching Web
  static const Color textPrimary = Color(0xFFFFFFFF); // #ffffff
  static const Color textSecondary = Color(0xFF9E9E9E); // #9e9e9e
  static const Color textMuted = Color(0xFF666666); // #666666

  // Borders & Dividers matching Web
  static const Color borderSubtle = Color(0xFF1E1E1E); // #1e1e1e
  static const Color borderHighlight = Color(0xFFE5C158); // #e5c158
  static const Color borderMedium = Color(0xFF2E2E2E); // #2e2e2e

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, accentGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = goldGradient;

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x20E5C158), Color(0x05E5C158)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
