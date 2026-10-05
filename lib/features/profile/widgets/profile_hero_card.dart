import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/dio_client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../auth/models/user_model.dart';

class ProfileHeroCard extends ConsumerWidget {
  final UserModel user;
  final bool isUploading;
  final VoidCallback onPickAvatar;
  final String lang;
  final bool isDark;

  const ProfileHeroCard({
    super.key,
    required this.user,
    required this.isUploading,
    required this.onPickAvatar,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = isDark ? const Color(0xFF14131C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentGold = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final hasGoogleLogin = user.hasGoogleLogin;
    final apiBaseUrl = ref.watch(apiBaseUrlProvider).valueOrNull ??
        ref.watch(dioClientProvider).options.baseUrl;
    final avatarUrl = user.avatarUrlForBase(apiBaseUrl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentGold.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Gold Glow Ring & Camera overlay
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentGold, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: accentGold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    width: 92,
                    height: 92,
                    color: isDark ? const Color(0xFF221F33) : const Color(0xFFE2E8F0),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentGold,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                user.initials,
                                style: TextStyle(
                                  color: accentGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: accentGold,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploading ? null : onPickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Display Name
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline_rounded, size: 14, color: textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  user.email.isNotEmpty ? user.email : 'No email',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Role & Auth Provider Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isAdmin
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: user.isAdmin ? const Color(0xFFEF4444) : accentGold,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.isAdmin ? Icons.shield_rounded : Icons.star_rounded,
                      size: 13,
                      color: user.isAdmin ? const Color(0xFFEF4444) : accentGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.isAdmin ? 'ADMINISTRATOR' : user.role.toUpperCase(),
                      style: TextStyle(
                        color: user.isAdmin ? const Color(0xFFEF4444) : accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Auth Provider Pill (Google / Local)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasGoogleLogin) ...[
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          'assets/icons/google_g.png',
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 10, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.hasLocalLogin ? 'Google + Local' : 'Google',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.lock_person_outlined, size: 13, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        lang == 'vi' ? 'Mật khẩu cục bộ' : 'Local Account',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
