import 'package:flutter/material.dart';
import '../widgets/my_life_module_card.dart';
import '../../family_tree/views/family_tree_screen.dart';
import '../../anniversary/views/anniversary_screen.dart';
import '../../library/views/library_screen.dart';
import '../../family_map/views/family_map_screen.dart';

class MyLifeHubScreen extends StatelessWidget {
  const MyLifeHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final vi = lang == 'vi';
    final modules = <(IconData, String, String, Color, Widget)>[
      (
        Icons.account_tree_rounded,
        vi ? 'Gia phả' : 'Family Tree',
        vi
            ? 'Khám phá các thế hệ và thành viên trong gia đình.'
            : 'Explore family members and generations.',
        const Color(0xFFB58900),
        const FamilyTreeScreen()
      ),
      (
        Icons.event_available_rounded,
        vi ? 'Ngày kỷ niệm' : 'Anniversaries',
        vi
            ? 'Theo dõi ngày giỗ và sự kiện gia đình.'
            : 'Keep track of memorial days and family events.',
        Colors.deepOrange,
        const AnniversaryScreen()
      ),
      (
        Icons.photo_library_rounded,
        vi ? 'Thư viện' : 'Library',
        vi
            ? 'Lưu giữ ảnh và câu chuyện gia đình.'
            : 'Keep family photos and stories together.',
        Colors.indigo,
        const LibraryScreen()
      ),
      (
        Icons.map_rounded,
        vi ? 'Bản đồ gia đình' : 'Family Map',
        vi
            ? 'Xem các thành viên đang sinh sống ở đâu.'
            : 'See where family members live.',
        Colors.teal,
        const FamilyMapScreen()
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(vi ? 'MyLife' : 'MyLife')),
      body: CustomScrollView(slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      vi
                          ? 'Cuộc sống gia đình, kết nối trong một nơi'
                          : 'Your family life, connected in one place',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                      vi
                          ? 'Chọn một không gian để bắt đầu.'
                          : 'Choose a space to get started.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ]))),
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .91,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8),
              itemCount: modules.length,
              itemBuilder: (context, i) {
                final item = modules[i];
                return MyLifeModuleCard(
                    icon: item.$1,
                    title: item.$2,
                    description: item.$3,
                    openLabel: vi ? 'Mở' : 'Open',
                    color: item.$4,
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => item.$5)));
              },
            )),
      ]),
    );
  }
}
