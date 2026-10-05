import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/models/user_model.dart';
import '../models/admin_stats_model.dart';
import '../models/admin_user_model.dart';
import '../services/admin_api_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AdminStatsModel? _stats;
  List<AdminUserModel> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<int> _pendingUserIds = <int>{};
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool showLoading = true}) async {
    if (mounted && showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final adminService = ref.read(adminApiServiceProvider);
      final stats = await adminService.getStats();
      final users = await adminService.getUsers(search: _searchController.text.trim());
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _users = users;
      });
    } catch (error, stackTrace) {
      debugPrint('Admin data load failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _errorMessage = ApiError.message(
              error,
              fallback: 'Unable to load administrator data. Please try again.',
            ));
      }
    } finally {
      if (mounted && showLoading) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(AdminUserModel user) async {
    _setUserPending(user.id, true);
    try {
      final adminService = ref.read(adminApiServiceProvider);
      await adminService.toggleUserStatus(user.id, !user.isActive);
      await _fetchData(showLoading: false);
    } catch (error, stackTrace) {
      _showActionError('update this account status', error, stackTrace);
    } finally {
      _setUserPending(user.id, false);
    }
  }

  Future<void> _changeRole(AdminUserModel user) async {
    final nextRole = user.isAdmin ? UserModel.roleUser : UserModel.roleAdmin;
    _setUserPending(user.id, true);
    try {
      final adminService = ref.read(adminApiServiceProvider);
      await adminService.changeUserRole(user.id, nextRole);
      await _fetchData(showLoading: false);
    } catch (error, stackTrace) {
      _showActionError('change this account role', error, stackTrace);
    } finally {
      _setUserPending(user.id, false);
    }
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vĩnh viễn tài khoản ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _setUserPending(user.id, true);
      try {
        final adminService = ref.read(adminApiServiceProvider);
        await adminService.deleteUser(user.id);
        await _fetchData(showLoading: false);
      } catch (error, stackTrace) {
        _showActionError('delete this account', error, stackTrace);
      } finally {
        _setUserPending(user.id, false);
      }
    }
  }

  void _setUserPending(int id, bool isPending) {
    if (!mounted) return;
    setState(() {
      if (isPending) {
        _pendingUserIds.add(id);
      } else {
        _pendingUserIds.remove(id);
      }
    });
  }

  void _showActionError(String action, Object error, StackTrace stackTrace) {
    debugPrint('Unable to $action: $error\n$stackTrace');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(ApiError.message(
          error,
          fallback: 'Unable to $action. Please try again.',
        )),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage!)),
                          TextButton(
                            onPressed: _fetchData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Stat Cards Grid
                  if (_stats != null) ...[
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('TỔNG USERS', _stats!.totalUsers.toString(), Icons.people, AppColors.accentCyan)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard('HOẠT ĐỘNG', _stats!.totalActive.toString(), Icons.check_circle, AppColors.success)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard('BỊ KHÓA', _stats!.totalLocked.toString(), Icons.lock, AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchData(),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên hoặc email...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.accentCyan),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchData();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Users List Header
                  Text(
                    'DANH SÁCH TÀI KHOẢN (${_users.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // User Cards
                  ..._users.map((u) => GlassContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.surfaceBg,
                                  child: Text(
                                    (u.fullName?.isNotEmpty == true ? u.fullName![0] : u.email[0]).toUpperCase(),
                                    style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(u.fullName ?? 'Chưa đặt tên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(u.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: u.isAdmin ? AppColors.accentCyan.withValues(alpha: 0.2) : AppColors.surfaceBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: u.isAdmin ? AppColors.accentCyan : AppColors.borderSubtle),
                                  ),
                                  child: Text(u.role, style: TextStyle(color: u.isAdmin ? AppColors.accentCyanLight : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: Icon(u.isActive ? Icons.lock_outline : Icons.lock_open, size: 16),
                                  label: Text(u.isActive ? 'Khóa' : 'Mở khóa', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: u.isActive ? AppColors.warning : AppColors.success,
                                    side: BorderSide(color: u.isActive ? AppColors.warning : AppColors.success),
                                  ),
                                  onPressed: _pendingUserIds.contains(u.id) ? null : () => _toggleStatus(u),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.swap_horiz, size: 16),
                                  label: Text(u.isAdmin ? 'Gỡ Admin' : 'Lên Admin', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accentCyan,
                                    side: const BorderSide(color: AppColors.accentCyan),
                                  ),
                                  onPressed: _pendingUserIds.contains(u.id) ? null : () => _changeRole(u),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: _pendingUserIds.contains(u.id) ? null : () => _deleteUser(u),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
