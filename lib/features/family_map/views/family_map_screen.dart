import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/theme/app_colors.dart';
import '../models/family_map_data.dart';
import '../providers/family_map_provider.dart';

class FamilyMapScreen extends ConsumerWidget {
  const FamilyMapScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final vi = lang == 'vi';
    final state = ref.watch(familyMapProvider);
    final data = state.valueOrNull;
    return Scaffold(
        appBar: AppBar(
            title: Text(vi ? 'Bản đồ gia đình' : 'Family Map'),
            actions: [
              IconButton(
                  onPressed: () =>
                      ref.read(familyMapProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh))
            ]),
        body: state.isLoading && data == null
            ? const Center(child: CircularProgressIndicator())
            : state.hasError && data == null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${state.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                        onPressed: () =>
                            ref.read(familyMapProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: Text(vi ? 'Thử lại' : 'Retry'))
                  ]))
                : data == null
                    ? const SizedBox.shrink()
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(familyMapProvider.notifier).refresh(),
                        child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                _stat(vi ? 'Tổng thành viên' : 'Total members',
                                    data.totalMembers),
                                _stat(vi ? 'Có vị trí' : 'Located',
                                    data.locatedMembers),
                                _stat(vi ? 'Chưa định vị' : 'Unlocated',
                                    data.unlocatedMembers),
                                _stat(vi ? 'Khu vực' : 'Regions',
                                    data.locations.length)
                              ]),
                              const SizedBox(height: 12),
                              SizedBox(
                                  height: 440,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: FlutterMap(
                                          options: MapOptions(
                                              initialCenter: data
                                                      .locations.isEmpty
                                                  ? const LatLng(16.0, 106.0)
                                                  : _center(data.locations),
                                              initialZoom:
                                                  data.locations.length > 1
                                                      ? 5.2
                                                      : 6.0,
                                              initialCameraFit: data
                                                          .locations.length >
                                                      1
                                                  ? CameraFit.bounds(
                                                      bounds: _bounds(
                                                          data.locations),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              35))
                                                  : null),
                                          children: [
                                            TileLayer(
                                                urlTemplate:
                                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                userAgentPackageName:
                                                    'com.mylife.mobile'),
                                            MarkerLayer(
                                                markers: data.locations
                                                    .map((loc) => Marker(
                                                        point: LatLng(
                                                            loc.latitude,
                                                            loc.longitude),
                                                        width: 72,
                                                        height: 60,
                                                        child: GestureDetector(
                                                            onTap: () =>
                                                                _members(
                                                                    context,
                                                                    loc,
                                                                    vi),
                                                            child: Column(
                                                                children: [
                                                                  Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              6),
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              AppColors.accentGoldDark,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color: Colors.black.withValues(alpha: .22),
                                                                                blurRadius: 6)
                                                                          ]),
                                                                      child: Text(
                                                                          '${loc.memberCount}',
                                                                          style: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold))),
                                                                  const Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color: AppColors
                                                                          .accentGoldDark,
                                                                      size: 24)
                                                                ]))))
                                                    .toList()),
                                            const RichAttributionWidget(
                                                attributions: [
                                                  TextSourceAttribution(
                                                      '© OpenStreetMap contributors')
                                                ])
                                          ]))),
                              const SizedBox(height: 12),
                              _stat(
                                  vi ? 'Đang chờ định vị' : 'Pending geocoding',
                                  data.pendingGeocodingMembers),
                              _stat(vi ? 'Không có địa chỉ' : 'No address',
                                  data.noAddressMembers),
                              _stat(
                                  vi ? 'Định vị thất bại' : 'Geocoding failed',
                                  data.failedGeocodingMembers),
                              if (data.locations.isEmpty)
                                Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                        vi
                                            ? 'Chưa có địa chỉ nào được định vị.'
                                            : 'No member locations are available yet.',
                                        textAlign: TextAlign.center)),
                            ])));
  }

  static LatLng _center(List<FamilyMapLocation> locs) => LatLng(
      locs.map((e) => e.latitude).reduce((a, b) => a + b) / locs.length,
      locs.map((e) => e.longitude).reduce((a, b) => a + b) / locs.length);
  static LatLngBounds _bounds(List<FamilyMapLocation> locs) {
    var minLat = locs.first.latitude,
        maxLat = minLat,
        minLon = locs.first.longitude,
        maxLon = minLon;
    for (final l in locs) {
      if (l.latitude < minLat) minLat = l.latitude;
      if (l.latitude > maxLat) maxLat = l.latitude;
      if (l.longitude < minLon) minLon = l.longitude;
      if (l.longitude > maxLon) maxLon = l.longitude;
    }
    return LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
  }

  static Widget _stat(String label, int value) => Card(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text('$label  ·  $value')));
  static void _members(
          BuildContext context, FamilyMapLocation location, bool vi) =>
      showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (ctx) => SafeArea(
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(location.displayName,
                    style: Theme.of(ctx).textTheme.titleLarge),
                Text(
                    '${location.memberCount} ${vi ? 'thành viên' : 'members'}'),
                const Divider(),
                ...location.members.map((m) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(m.fullName),
                    subtitle:
                        Text('${vi ? 'Đời' : 'Generation'} ${m.generation}')))
              ])));
}
