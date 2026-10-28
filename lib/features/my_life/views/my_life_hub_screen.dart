import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/mylife_design_tokens.dart';
import '../../anniversary/models/family_anniversary.dart';
import '../../anniversary/providers/anniversary_provider.dart';
import '../../anniversary/views/anniversary_screen.dart';
import '../../family_map/views/family_map_screen.dart';
import '../../family_tree/providers/family_tree_provider.dart';
import '../../family_tree/views/family_tree_screen.dart';
import 'family_timeline_screen.dart';
import '../../library/models/library_models.dart';
import '../../library/providers/library_provider.dart';
import '../../library/views/library_screen.dart';

class MyLifeHubScreen extends ConsumerStatefulWidget {
  const MyLifeHubScreen({super.key});

  @override
  ConsumerState<MyLifeHubScreen> createState() => _MyLifeHubScreenState();
}

class _MyLifeHubScreenState extends ConsumerState<MyLifeHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tree = ref.read(familyTreeProvider);
      if (tree.members.isEmpty && !tree.isLoading) {
        ref.read(familyTreeProvider.notifier).load();
      }
      ref.read(anniversaryProvider);
      ref.read(libraryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final tree = ref.watch(familyTreeProvider);
    final anniversaries =
        ref.watch(anniversaryProvider).valueOrNull ?? const [];
    final albums = ref.watch(libraryProvider).valueOrNull ?? const [];
    final todayItems = _todayItems(anniversaries);
    final recentPhoto = _recentCover(albums);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('MyLife'),
            actions: [
              IconButton(
                tooltip: vi ? 'Gia phả' : 'Family tree',
                onPressed: () => _open(context, const FamilyTreeScreen()),
                icon: const Icon(Icons.account_tree_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            sliver: SliverList.list(children: [
              Text(vi ? 'Câu chuyện của gia đình' : 'Your family story',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                        letterSpacing: -0.7,
                      )),
              const SizedBox(height: 18),
              _FamilyHero(
                count: tree.members.length,
                generationCount:
                    tree.members.map((m) => m.generation).toSet().length,
                isLoading: tree.isLoading,
                error: tree.errorMessage,
                isDark: isDark,
                vi: vi,
                onTap: () => _open(context, const FamilyTreeScreen()),
              ),
              const SizedBox(height: 30),
              _SectionHeading(
                title: vi ? 'Hôm nay trong gia đình' : 'Today in your family',
                action:
                    todayItems.isEmpty ? null : (vi ? 'Xem lịch' : 'Calendar'),
                onAction: todayItems.isEmpty
                    ? null
                    : () => _open(context, const AnniversaryScreen()),
              ),
              const SizedBox(height: 12),
              if (todayItems.isEmpty)
                _QuietDay(vi: vi)
              else
                ...todayItems.map((item) => _TodayItem(item: item, vi: vi)),
              const SizedBox(height: 30),
              _SectionHeading(
                  title: vi ? 'Không gian gia đình' : 'Family spaces'),
              const SizedBox(height: 12),
              _FamilySpaceTile(
                title: vi ? 'Gia phả' : 'Family tree',
                subtitle: vi
                    ? 'Các thế hệ và chân dung'
                    : 'Generations and portraits',
                icon: Icons.account_tree_rounded,
                accent: MyLifeDesign.sage,
                onTap: () => _open(context, const FamilyTreeScreen()),
              ),
              const SizedBox(height: 10),
              _FamilySpaceTile(
                title: vi ? 'Ngày giỗ & kỷ niệm' : 'Anniversaries',
                subtitle: vi
                    ? 'Những ngày gia đình cùng nhớ'
                    : 'Dates your family remembers',
                icon: Icons.event_note_rounded,
                accent: MyLifeDesign.amber,
                onTap: () => _open(context, const AnniversaryScreen()),
              ),
              const SizedBox(height: 10),
              _FamilySpaceTile(
                title: vi ? 'Bản đồ gia đình' : 'Family map',
                subtitle: vi
                    ? 'Nơi người thân đang sinh sống'
                    : 'Where your relatives live',
                icon: Icons.map_outlined,
                accent: MyLifeDesign.teal,
                onTap: () => _open(context, const FamilyMapScreen()),
              ),
              const SizedBox(height: 10),
              _FamilySpaceTile(
                title: vi ? 'Dòng thời gian' : 'Family timeline',
                subtitle: vi
                    ? 'Những dấu mốc qua từng năm'
                    : 'Milestones across the years',
                icon: Icons.timeline_rounded,
                accent: MyLifeDesign.teal,
                onTap: () => _open(context, const FamilyTimelineScreen()),
              ),
              const SizedBox(height: 30),
              _SectionHeading(
                title: vi ? 'Ký ức gần đây' : 'Recent memories',
                action: vi ? 'Mở thư viện' : 'Open library',
                onAction: () => _open(context, const LibraryScreen()),
              ),
              const SizedBox(height: 12),
              _RecentMemory(
                photo: recentPhoto,
                albumCount: albums.length,
                vi: vi,
                onTap: () => _open(context, const LibraryScreen()),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  List<FamilyAnniversary> _todayItems(List<FamilyAnniversary> items) {
    final today = DateTime.now();
    return items.where((item) {
      final date = item.nextSolarDate;
      return date.month == today.month && date.day == today.day;
    }).toList();
  }

  String? _recentCover(List<LibraryAlbum> albums) {
    for (final album in albums) {
      final cover =
          album.photos.where((photo) => photo.id == album.coverPhotoId);
      if (cover.isNotEmpty && cover.first.url.isNotEmpty) {
        return cover.first.url;
      }
      if (album.photos.isNotEmpty && album.photos.first.url.isNotEmpty) {
        return album.photos.first.url;
      }
    }
    return null;
  }

  void _open(BuildContext context, Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _FamilyHero extends StatelessWidget {
  const _FamilyHero(
      {required this.count,
      required this.generationCount,
      required this.isLoading,
      required this.error,
      required this.isDark,
      required this.vi,
      required this.onTap});
  final int count;
  final int generationCount;
  final bool isLoading;
  final String? error;
  final bool isDark;
  final bool vi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? const Color(0xFFF7F2E8) : MyLifeDesign.ink;
    return Material(
      color: isDark ? MyLifeDesign.surfaceDark : MyLifeDesign.surfaceLight,
      borderRadius: BorderRadius.circular(MyLifeDesign.heroRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 250,
          child: Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _FamilyIllustrationPainter(isDark: isDark)),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vi ? 'GIA ĐÌNH CỦA BẠN' : 'YOUR FAMILY',
                        style: TextStyle(
                            color: foreground.withValues(alpha: .64),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(
                        vi
                            ? 'Nơi câu chuyện tiếp nối'
                            : 'Where stories continue',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: foreground, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(
                        error != null
                            ? (vi
                                ? 'Chưa thể tải dữ liệu gia đình'
                                : 'Family details are unavailable')
                            : isLoading && count == 0
                                ? (vi
                                    ? 'Đang kết nối với gia đình…'
                                    : 'Connecting to your family…')
                                : count == 0
                                    ? (vi
                                        ? 'Thêm thành viên đầu tiên để bắt đầu'
                                        : 'Add your first family member to begin')
                                    : '$count ${vi ? 'thành viên' : (count == 1 ? 'member' : 'members')}'
                                        '${generationCount > 0 ? ' · $generationCount ${vi ? 'thế hệ' : (generationCount == 1 ? 'generation' : 'generations')}' : ''}',
                        style: TextStyle(
                            color: foreground.withValues(alpha: .72),
                            fontSize: 13)),
                  ]),
            ),
            Positioned(
                right: 17,
                bottom: 19,
                child: Icon(Icons.arrow_forward_rounded,
                    color: foreground.withValues(alpha: .7))),
          ]),
        ),
      ),
    );
  }
}

class _FamilyIllustrationPainter extends CustomPainter {
  const _FamilyIllustrationPainter({required this.isDark});
  final bool isDark;
  @override
  void paint(Canvas canvas, Size size) {
    final base = isDark ? const Color(0xFF3C4738) : const Color(0xFFDCE2D1);
    final wash = Paint()..color = base.withValues(alpha: isDark ? .42 : .72);
    canvas.drawCircle(Offset(size.width * .73, size.height * .21), 76, wash);
    final line = Paint()
      ..color =
          (isDark ? Colors.white : MyLifeDesign.sage).withValues(alpha: .22)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * .34, size.height * .42)
      ..quadraticBezierTo(size.width * .5, size.height * .17, size.width * .67,
          size.height * .38)
      ..moveTo(size.width * .5, size.height * .28)
      ..lineTo(size.width * .5, size.height * .53)
      ..moveTo(size.width * .34, size.height * .42)
      ..lineTo(size.width * .34, size.height * .53)
      ..moveTo(size.width * .67, size.height * .38)
      ..lineTo(size.width * .67, size.height * .53);
    canvas.drawPath(path, line);
    final centers = [
      Offset(size.width * .34, size.height * .4),
      Offset(size.width * .5, size.height * .26),
      Offset(size.width * .67, size.height * .36)
    ];
    for (var i = 0; i < centers.length; i++) {
      final color =
          [MyLifeDesign.sage, MyLifeDesign.amber, MyLifeDesign.teal][i];
      canvas.drawCircle(
          centers[i], 17, Paint()..color = color.withValues(alpha: .78));
      canvas.drawCircle(centers[i].translate(0, 1), 5,
          Paint()..color = Colors.white.withValues(alpha: .84));
    }
    final ground = Paint()..color = base.withValues(alpha: .48);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * .52, size.height * .66),
            width: size.width * .8,
            height: 32),
        ground);
  }

  @override
  bool shouldRepaint(covariant _FamilyIllustrationPainter oldDelegate) =>
      isDark != oldDelegate.isDark;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -.3))),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ]);
}

class _QuietDay extends StatelessWidget {
  const _QuietDay({required this.vi});
  final bool vi;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(MyLifeDesign.cardRadius)),
        child: Row(children: [
          const Icon(Icons.wb_sunny_outlined, color: MyLifeDesign.amber),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  vi
                      ? 'Một ngày bình yên trong gia đình.'
                      : 'A quiet day with family.',
                  style: Theme.of(context).textTheme.bodyMedium)),
        ]),
      );
}

class _TodayItem extends StatelessWidget {
  const _TodayItem({required this.item, required this.vi});
  final FamilyAnniversary item;
  final bool vi;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(MyLifeDesign.cardRadius)),
          child: Row(children: [
            const Icon(Icons.event_rounded, color: MyLifeDesign.amber),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (item.relatedMemberName?.isNotEmpty == true)
                    Text(item.relatedMemberName!,
                        style: Theme.of(context).textTheme.bodySmall),
                ])),
            Text(vi ? 'Hôm nay' : 'Today',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: MyLifeDesign.amber, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _FamilySpaceTile extends StatelessWidget {
  const _FamilySpaceTile(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.accent,
      required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(MyLifeDesign.cardRadius),
        child: InkWell(
            borderRadius: BorderRadius.circular(MyLifeDesign.cardRadius),
            onTap: onTap,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: accent.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(15)),
                      child: Icon(icon, color: accent)),
                  const SizedBox(width: 13),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                      ])),
                  const Icon(Icons.chevron_right_rounded),
                ]))),
      );
}

class _RecentMemory extends StatelessWidget {
  const _RecentMemory(
      {required this.photo,
      required this.albumCount,
      required this.vi,
      required this.onTap});
  final String? photo;
  final int albumCount;
  final bool vi;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(MyLifeDesign.largeRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: SizedBox(
                height: 168,
                child: Stack(fit: StackFit.expand, children: [
                  if (photo != null)
                    Image.network(photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _emptyVisual(context))
                  else
                    _emptyVisual(context),
                  DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: .72)
                      ]))),
                  Positioned(
                      left: 17,
                      right: 17,
                      bottom: 15,
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  albumCount == 0
                                      ? (vi
                                          ? 'Album gia đình'
                                          : 'Family albums')
                                      : (vi
                                          ? 'Lưu giữ khoảnh khắc'
                                          : 'Keep a moment close'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                              const SizedBox(height: 3),
                              Text(
                                  albumCount == 0
                                      ? (vi
                                          ? 'Thêm những bức ảnh đầu tiên'
                                          : 'Add your first family photos')
                                      : '$albumCount ${vi ? 'album' : (albumCount == 1 ? 'album' : 'albums')}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ])),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white),
                      ])),
                ]))),
      );
  Widget _emptyVisual(BuildContext context) => Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? MyLifeDesign.raisedDark
            : const Color(0xFFE7E0D2),
        child: Center(
            child: Icon(Icons.photo_library_outlined,
                size: 52, color: MyLifeDesign.violet.withValues(alpha: .65))),
      );
}
