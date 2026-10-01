import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../auth/models/user_model.dart';

class ProfileDetailsTab extends StatelessWidget {
  final UserModel user;
  final String lang;
  final bool isDark;
  final VoidCallback onEditProfile;

  const ProfileDetailsTab({
    super.key,
    required this.user,
    required this.lang,
    required this.isDark,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF14131C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentGold = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: accentGold),
              const SizedBox(width: 8),
              Text(
                lang == 'vi' ? 'CHI TIẾT TÀI KHOẢN' : 'ACCOUNT DETAILS',
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditProfile,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentGold.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 13, color: accentGold),
                        const SizedBox(width: 5),
                        Text(
                          lang == 'vi' ? 'Chỉnh sửa' : 'Edit',
                          style: TextStyle(
                            color: accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: cardBorder, height: 22),

          _buildDetailTile(
            icon: Icons.person_outline_rounded,
            label: lang == 'vi' ? 'Họ và tên' : 'Full Name',
            value: user.displayName,
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _buildDetailTile(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: user.email.isNotEmpty ? user.email : (lang == 'vi' ? 'Chưa cập nhật' : 'Not updated'),
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            badgeText: user.email.isNotEmpty ? (lang == 'vi' ? 'Đã xác minh' : 'Verified') : null,
            badgeColor: AppColors.success,
          ),
          _buildDetailTile(
            icon: Icons.phone_android_rounded,
            label: lang == 'vi' ? 'Số điện thoại' : 'Phone Number',
            value: (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty)
                ? user.phoneNumber!
                : (lang == 'vi' ? 'Chưa cập nhật' : 'Not updated'),
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _buildDetailTile(
            icon: Icons.wc_rounded,
            label: lang == 'vi' ? 'Giới tính' : 'Gender',
            value: (user.gender != null && user.gender!.trim().isNotEmpty)
                ? user.gender!
                : (lang == 'vi' ? 'Chưa cập nhật' : 'Not specified'),
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _buildDetailTile(
            icon: Icons.cake_outlined,
            label: lang == 'vi' ? 'Ngày sinh' : 'Date of Birth',
            value: (user.dateOfBirth != null && user.dateOfBirth!.trim().isNotEmpty)
                ? user.dateOfBirth!
                : (lang == 'vi' ? 'Chưa cập nhật' : 'Not specified'),
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          _buildDetailTile(
            icon: Icons.verified_user_outlined,
            label: lang == 'vi' ? 'Trạng thái hoạt động' : 'Account Status',
            value: '',
            isDark: isDark,
            accentColor: accentGold,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            badgeText: user.isActive ? 'ACTIVE' : 'LOCKED',
            badgeColor: user.isActive ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? accentColor).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (badgeColor ?? accentColor).withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor ?? accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (value.isNotEmpty) ...[
                  if (badgeText != null) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
