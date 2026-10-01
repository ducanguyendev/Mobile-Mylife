import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/avatar_api_service.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/profile_details_tab.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/profile_security_tab.dart';
import '../widgets/unauthenticated_profile_card.dart';
import '../../family_tree/views/family_tree_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar(String lang) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (picked != null) {
      setState(() => _isUploading = true);
      try {
        final avatarService = ref.read(avatarApiServiceProvider);
        final url = await avatarService.uploadAvatar(File(picked.path));
        if (url != null) {
          ref.read(authStateProvider.notifier).updateAvatarLocally(url);
          await ref.read(authStateProvider.notifier).checkAuth();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.success,
                content: Text(
                  lang == 'vi'
                      ? 'Cập nhật ảnh đại diện thành công!'
                      : 'Avatar updated successfully!',
                ),
              ),
            );
          }
        } else {
          throw Exception('Upload failed');
        }
      } catch (e) {
        String errorMsg = lang == 'vi'
            ? 'Lỗi khi tải ảnh lên. Vui lòng thử lại.'
            : 'Failed to upload avatar. Please try again.';
        if (e is DioException) {
          if (e.response?.statusCode == 401) {
            errorMsg = lang == 'vi'
                ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
                : 'Session expired. Please log in again.';
          } else if (e.response?.data != null && e.response?.data is Map && e.response?.data['message'] != null) {
            errorMsg = e.response!.data['message'].toString();
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(errorMsg),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  void _showEditProfileDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(user: user),
    );
  }

  void _confirmLogout(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Text(
              lang == 'vi' ? 'Đăng xuất tài khoản' : 'Sign Out',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          lang == 'vi'
              ? 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng MyLife?'
              : 'Are you sure you want to sign out of MyLife?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang == 'vi' ? 'Hủy' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).logout();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(lang == 'vi' ? 'Đăng xuất' : 'Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
    final cardBorder = isDark ? const Color(0xFF262338) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentGold = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;

    if (!authState.isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const UnauthenticatedProfileCard(),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F0E17) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'vi' ? 'HỒ SƠ CỦA TÔI' : 'MY PROFILE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_tree,
              color: textPrimary,
              size: 22,
            ),
            tooltip: lang == 'vi' ? 'Gia phả' : 'Family Tree',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FamilyTreeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: accentGold,
              size: 22,
            ),
            tooltip: 'Chế độ Sáng/Tối',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // 1. HERO PROFILE CARD
            ProfileHeroCard(
              user: user,
              isUploading: _isUploading,
              onPickAvatar: () => _pickAndUploadAvatar(lang),
              lang: lang,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 2. TAB CONTROLS (Thông tin & Bảo mật)
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14131C) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: accentGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    text: lang == 'vi' ? 'Thông tin cá nhân' : 'Personal Info',
                  ),
                  Tab(
                    icon: const Icon(Icons.security_rounded, size: 18),
                    text: lang == 'vi' ? 'Bảo mật & Cài đặt' : 'Security & Settings',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. TAB CONTENT
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return ProfileDetailsTab(
                    user: user,
                    lang: lang,
                    isDark: isDark,
                    onEditProfile: () => _showEditProfileDialog(user),
                  );
                } else {
                  return ProfileSecurityTab(
                    user: user,
                    lang: lang,
                    isDark: isDark,
                    onChangePassword: _showChangePasswordDialog,
                    onLogout: () => _confirmLogout(context, lang),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
