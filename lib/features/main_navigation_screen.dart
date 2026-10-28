import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_colors.dart';
import 'admin/views/admin_dashboard_screen.dart';
import 'auth/providers/auth_provider.dart';
import 'profile/views/profile_screen.dart';
import 'my_life/views/my_life_hub_screen.dart';
import 'my_life/views/family_timeline_screen.dart';
import 'family_tree/views/family_tree_screen.dart';
import 'anniversary/views/anniversary_screen.dart';
import 'library/views/library_screen.dart';
import 'family_map/views/family_map_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.isAdmin;

    final screens = <Widget>[
      const MyLifeHubScreen(),
      const FamilyTreeScreen(),
      const _MemoryHomeScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminDashboardScreen(),
    ];

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Trang chủ'),
          const NavigationDestination(
              icon: Icon(Icons.account_tree_outlined),
              selectedIcon: Icon(Icons.account_tree),
              label: 'Gia đình'),
          const NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Ký ức'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Tôi'),
          if (isAdmin)
            const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: 'Quản trị'),
        ],
      ),
    );
  }
}

class _MemoryHomeScreen extends StatelessWidget {
  const _MemoryHomeScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ký ức')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Những điều gia đình cùng nhớ',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          _MemoryDestination(
              icon: Icons.event_note_rounded,
              title: 'Ngày giỗ & kỷ niệm',
              subtitle: 'Lịch âm, ngày dương và dịp sum họp',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AnniversaryScreen()))),
          _MemoryDestination(
              icon: Icons.timeline_rounded,
              title: 'Dòng thời gian',
              subtitle: 'Các dấu mốc qua từng năm',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FamilyTimelineScreen()))),
          _MemoryDestination(
              icon: Icons.photo_library_outlined,
              title: 'Thư viện gia đình',
              subtitle: 'Album ảnh và câu chuyện',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LibraryScreen()))),
          _MemoryDestination(
              icon: Icons.map_outlined,
              title: 'Bản đồ gia đình',
              subtitle: 'Những nơi người thân gọi là nhà',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FamilyMapScreen()))),
        ]),
      );
}

class _MemoryDestination extends StatelessWidget {
  const _MemoryDestination(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
          child: ListTile(
              leading: Icon(icon, color: AppColors.accentGold),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onTap)));
}
