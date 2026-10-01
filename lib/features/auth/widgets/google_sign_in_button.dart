import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    // Red segment
    final pathRed = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -2.35,
        1.6,
        false,
      )
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.35)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        -0.75,
        -1.6,
        false,
      )
      ..close();

    // Yellow segment
    final pathYellow = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.95,
        1.6,
        false,
      )
      ..lineTo(center.dx - radius * 0.55, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        -2.35,
        -1.6,
        false,
      )
      ..close();

    // Green segment
    final pathGreen = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0.8,
        1.55,
        false,
      )
      ..lineTo(center.dx + radius * 0.55, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        2.35,
        -1.55,
        false,
      )
      ..close();

    // Blue segment
    final pathBlue = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.75,
        1.55,
        false,
      )
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.35)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        5.0,
        -1.5,
        false,
      )
      ..close();

    canvas.drawPath(pathRed, paintRed);
    canvas.drawPath(pathYellow, paintYellow);
    canvas.drawPath(pathGreen, paintGreen);
    canvas.drawPath(pathBlue, paintBlue);

    // Crossbar for G
    final crossBar = Path()
      ..moveTo(center.dx, center.dy - radius * 0.2)
      ..lineTo(center.dx + radius * 0.95, center.dy - radius * 0.2)
      ..lineTo(center.dx + radius * 0.95, center.dy + radius * 0.2)
      ..lineTo(center.dx, center.dy + radius * 0.2)
      ..close();
    canvas.drawPath(crossBar, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  final String loadingLabel;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    required this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.02),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogoWidget(size: 18),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
