import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietmap;
import '../../../shared/theme/app_colors.dart';
import '../models/family_map_data.dart';
import '../providers/family_map_provider.dart';
import '../services/family_map_api_service.dart';

class _MapKeyMissing extends StatelessWidget {
  const _MapKeyMissing();
  @override
  Widget build(BuildContext context) => ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  'VIETMAP_TILE_KEY is missing. Run with --dart-define-from-file.',
                  textAlign: TextAlign.center))));
}

class _VietMapFamilyLayer extends StatefulWidget {
  const _VietMapFamilyLayer(
      {super.key,
      required this.apiKey,
      required this.camera,
      required this.zoom,
      required this.locations,
      required this.onMembers});
  final String apiKey;
  final LatLng camera;
  final double zoom;
  final List<FamilyMapLocation> locations;
  final ValueChanged<FamilyMapLocation> onMembers;
  @override
  State<_VietMapFamilyLayer> createState() => _VietMapFamilyLayerState();
}

class _VietMapFamilyLayerState extends State<_VietMapFamilyLayer> {
  vietmap.VietmapController? _controller;
  @override
  Widget build(BuildContext context) => Stack(children: [
        vietmap.VietmapGL(
          styleString:
              'https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=${Uri.encodeQueryComponent(widget.apiKey)}',
          initialCameraPosition: vietmap.CameraPosition(
              target: vietmap.LatLng(
                  widget.camera.latitude, widget.camera.longitude),
              zoom: widget.zoom),
          trackCameraPosition: true,
          onMapCreated: (controller) =>
              setState(() => _controller = controller),
        ),
        const Positioned(
            left: 8,
            bottom: 6,
            child: Text('© VIETMAP',
                style: TextStyle(fontSize: 10, color: Colors.black54))),
        if (_controller != null)
          vietmap.MarkerLayer(
              mapController: _controller!,
              markers: widget.locations
                  .map((location) => vietmap.Marker(
                        latLng: vietmap.LatLng(
                            location.latitude, location.longitude),
                        width: 72,
                        height: 60,
                        child: GestureDetector(
                            onTap: () => widget.onMembers(location),
                            child: Column(children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppColors.accentGoldDark,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: .22),
                                            blurRadius: 6)
                                      ]),
                                  child: Text('${location.memberCount}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                              const Icon(Icons.location_on,
                                  color: AppColors.accentGoldDark, size: 24),
                            ])),
                      ))
                  .toList(growable: false)),
      ]);
}

class _VietMapPickerLayer extends StatefulWidget {
  const _VietMapPickerLayer(
      {super.key,
      required this.apiKey,
      required this.point,
      required this.zoom,
      required this.onPick});
  final String apiKey;
  final LatLng point;
  final double zoom;
  final ValueChanged<LatLng> onPick;
  @override
  State<_VietMapPickerLayer> createState() => _VietMapPickerLayerState();
}

class _VietMapPickerLayerState extends State<_VietMapPickerLayer> {
  vietmap.VietmapController? _controller;
  @override
  Widget build(BuildContext context) => Stack(children: [
        vietmap.VietmapGL(
          styleString:
              'https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=${Uri.encodeQueryComponent(widget.apiKey)}',
          initialCameraPosition: vietmap.CameraPosition(
              target:
                  vietmap.LatLng(widget.point.latitude, widget.point.longitude),
              zoom: widget.zoom),
          trackCameraPosition: true,
          onMapCreated: (controller) =>
              setState(() => _controller = controller),
          onMapClick: (_, latLng) =>
              widget.onPick(LatLng(latLng.latitude, latLng.longitude)),
        ),
        const Positioned(
            left: 8,
            bottom: 6,
            child: Text('© VIETMAP',
                style: TextStyle(fontSize: 10, color: Colors.black54))),
        if (_controller != null)
          vietmap.MarkerLayer(mapController: _controller!, markers: [
            vietmap.Marker(
                latLng: vietmap.LatLng(
                    widget.point.latitude, widget.point.longitude),
                width: 44,
                height: 44,
                child: const Icon(Icons.location_pin,
                    color: AppColors.error, size: 40))
          ]),
      ]);
}

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
                  tooltip:
                      vi ? 'Chỉnh vị trí thành viên' : 'Adjust member location',
                  onPressed: data == null || data.members.isEmpty
                      ? null
                      : () => _pickLocation(context, ref, data, vi),
                  icon: const Icon(Icons.edit_location_alt_outlined)),
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
                                      child: _useNativeVietMap
                                          ? _familyMapBaseLayer(data.locations,
                                              onMembers: (loc) =>
                                                  _members(context, loc, vi))
                                          : !kIsWeb
                                              ? const _MapKeyMissing()
                                              : FlutterMap(
                                                  options: MapOptions(
                                                      initialCenter: data
                                                              .locations.isEmpty
                                                          ? const LatLng(
                                                              16.0, 106.0)
                                                          : _center(
                                                              data.locations),
                                                      initialZoom:
                                                          data.locations.length >
                                                                  1
                                                              ? 5.2
                                                              : 6.0,
                                                      initialCameraFit: data
                                                                  .locations
                                                                  .length >
                                                              1
                                                          ? CameraFit.bounds(
                                                              bounds: _bounds(
                                                                  data.locations),
                                                              padding: const EdgeInsets.all(35))
                                                          : null),
                                                  children: [
                                                      _familyMapBaseLayer(
                                                          data.locations,
                                                          onMembers: (loc) =>
                                                              _members(context,
                                                                  loc, vi)),
                                                      if (!_useNativeVietMap)
                                                        MarkerLayer(
                                                            markers: data
                                                                .locations
                                                                .where(
                                                                    _hasValidCoordinates)
                                                                .map((loc) => Marker(
                                                                    point: LatLng(loc.latitude, loc.longitude),
                                                                    width: 72,
                                                                    height: 60,
                                                                    child: GestureDetector(
                                                                        onTap: () => _members(context, loc, vi),
                                                                        child: Column(children: [
                                                                          Container(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      10,
                                                                                  vertical:
                                                                                      6),
                                                                              decoration: BoxDecoration(color: AppColors.accentGoldDark, borderRadius: BorderRadius.circular(20), boxShadow: [
                                                                                BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: 6)
                                                                              ]),
                                                                              child: Text('${loc.memberCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                                                          const Icon(
                                                                              Icons.location_on,
                                                                              color: AppColors.accentGoldDark,
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
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                  onPressed: data.members.isEmpty
                                      ? null
                                      : () =>
                                          _pickLocation(context, ref, data, vi),
                                  icon: const Icon(
                                      Icons.edit_location_alt_outlined),
                                  label: Text(vi
                                      ? 'Chỉnh vị trí thành viên'
                                      : 'Adjust member location')),
                            ])));
  }

  static Future<void> _pickLocation(
      BuildContext context, WidgetRef ref, FamilyMapData data, bool vi) async {
    var selected = data.members.first;
    LatLng? point = selected.latitude != null && selected.longitude != null
        ? LatLng(selected.latitude!, selected.longitude!)
        : null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(vi ? 'Chọn thành viên' : 'Choose a member',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selected.id,
                    isExpanded: true,
                    items: data.members
                        .map((member) => DropdownMenuItem<int>(
                            value: member.id,
                            child: Text(member.fullName,
                                overflow: TextOverflow.ellipsis)))
                        .toList(growable: false),
                    onChanged: (id) {
                      final next = data.members.firstWhere((m) => m.id == id);
                      setSheetState(() {
                        selected = next;
                        point = next.latitude != null && next.longitude != null
                            ? LatLng(next.latitude!, next.longitude!)
                            : null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(vi
                      ? 'Chạm vào bản đồ để đặt vị trí chính xác.'
                      : 'Tap the map to choose the precise location.'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _useNativeVietMap
                          ? _locationPickerBaseLayer(
                              memberId: selected.id,
                              initialPoint: point,
                              onPick: (latLng) =>
                                  setSheetState(() => point = latLng),
                            )
                          : !kIsWeb
                              ? const _MapKeyMissing()
                              : FlutterMap(
                                  key: ValueKey(selected.id),
                                  options: MapOptions(
                                    initialCenter:
                                        point ?? const LatLng(16.0, 106.0),
                                    initialZoom: point == null ? 5 : 13,
                                    onTap: (_, position) =>
                                        setSheetState(() => point = position),
                                  ),
                                  children: [
                                    _locationPickerBaseLayer(
                                      memberId: selected.id,
                                      initialPoint: point,
                                      onPick: (latLng) =>
                                          setSheetState(() => point = latLng),
                                    ),
                                    if (point != null && !_useNativeVietMap)
                                      MarkerLayer(markers: [
                                        Marker(
                                          point: point!,
                                          width: 44,
                                          height: 44,
                                          child: const Icon(Icons.location_pin,
                                              color: AppColors.error, size: 40),
                                        )
                                      ]),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point == null
                        ? (vi ? 'Chưa chọn vị trí' : 'No location selected')
                        : '${point!.latitude.toStringAsFixed(6)}, ${point!.longitude.toStringAsFixed(6)}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(vi ? 'Hủy' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: point == null
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(familyMapApiProvider)
                                      .updateMemberLocation(selected.id,
                                          point!.latitude, point!.longitude);
                                  if (!sheetContext.mounted) return;
                                  Navigator.pop(sheetContext);
                                  await ref
                                      .read(familyMapProvider.notifier)
                                      .refresh();
                                } catch (error) {
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(sheetContext)
                                        .showSnackBar(
                                            SnackBar(content: Text('$error')));
                                  }
                                }
                              },
                        child: Text(vi ? 'Xác nhận' : 'Confirm'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static LatLng _center(List<FamilyMapLocation> locs) {
    final valid = locs.where(_hasValidCoordinates).toList();
    if (valid.isEmpty) return const LatLng(16, 106);
    return LatLng(
        valid.map((e) => e.latitude).reduce((a, b) => a + b) / valid.length,
        valid.map((e) => e.longitude).reduce((a, b) => a + b) / valid.length);
  }

  static LatLngBounds _bounds(List<FamilyMapLocation> locs) {
    final valid = locs.where(_hasValidCoordinates).toList();
    if (valid.isEmpty) {
      return LatLngBounds(const LatLng(16, 106), const LatLng(16, 106));
    }
    var minLat = valid.first.latitude,
        maxLat = minLat,
        minLon = valid.first.longitude,
        maxLon = minLon;
    for (final l in valid) {
      if (l.latitude < minLat) minLat = l.latitude;
      if (l.latitude > maxLat) maxLat = l.latitude;
      if (l.longitude < minLon) minLon = l.longitude;
      if (l.longitude > maxLon) maxLon = l.longitude;
    }
    return LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
  }

  static bool _hasValidCoordinates(FamilyMapLocation location) =>
      location.latitude.isFinite &&
      location.longitude.isFinite &&
      location.latitude >= -90 &&
      location.latitude <= 90 &&
      location.longitude >= -180 &&
      location.longitude <= 180;

  static bool get _useNativeVietMap =>
      !kIsWeb &&
      const String.fromEnvironment('VIETMAP_TILE_KEY').trim().isNotEmpty;

  static double _fitZoom(List<FamilyMapLocation> locations) {
    final minLat =
        locations.map((item) => item.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat =
        locations.map((item) => item.latitude).reduce((a, b) => a > b ? a : b);
    final minLon =
        locations.map((item) => item.longitude).reduce((a, b) => a < b ? a : b);
    final maxLon =
        locations.map((item) => item.longitude).reduce((a, b) => a > b ? a : b);
    double mercatorY(double latitude) {
      final radians = latitude.clamp(-85.0511, 85.0511) * math.pi / 180;
      return (1 -
              math.log(math.tan(radians) + 1 / math.cos(radians)) / math.pi) /
          2;
    }

    final fraction = math.max((maxLon - minLon).abs() / 360,
        (mercatorY(maxLat) - mercatorY(minLat)).abs());
    if (fraction <= 0) return 13;
    return (math.log(300 / (256 * fraction)) / math.ln2)
        .clamp(3, 16)
        .toDouble();
  }

  static Widget _familyMapBaseLayer(List<FamilyMapLocation> locations,
      {required ValueChanged<FamilyMapLocation> onMembers}) {
    if (kIsWeb) {
      return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mylife.mobile');
    }
    final key = const String.fromEnvironment('VIETMAP_TILE_KEY').trim();
    if (key.isEmpty) return const _MapKeyMissing();
    final valid = locations.where(_hasValidCoordinates).toList();
    return _VietMapFamilyLayer(
      key: ValueKey(
          'family-${valid.map((l) => '${l.latitude},${l.longitude}').join('|')}'),
      apiKey: key,
      camera: valid.isEmpty ? const LatLng(16, 106) : _center(valid),
      zoom: valid.length == 1
          ? 13
          : valid.length > 1
              ? _fitZoom(valid)
              : 5,
      locations: valid,
      onMembers: onMembers,
    );
  }

  static Widget _locationPickerBaseLayer({
    required int memberId,
    required LatLng? initialPoint,
    required ValueChanged<LatLng> onPick,
  }) {
    if (kIsWeb) {
      return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mylife.mobile');
    }
    final key = const String.fromEnvironment('VIETMAP_TILE_KEY').trim();
    if (key.isEmpty) return const _MapKeyMissing();
    return _VietMapPickerLayer(
        key: ValueKey(memberId),
        apiKey: key,
        point: initialPoint ?? const LatLng(16, 106),
        zoom: initialPoint == null ? 5 : 13,
        onPick: onPick);
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
