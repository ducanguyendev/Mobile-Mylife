import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_map_data.dart';
import '../services/family_map_api_service.dart';

final familyMapProvider =
    AsyncNotifierProvider<FamilyMapNotifier, FamilyMapData>(
        FamilyMapNotifier.new);

class FamilyMapNotifier extends AsyncNotifier<FamilyMapData> {
  @override
  Future<FamilyMapData> build() => ref.read(familyMapApiProvider).load();
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(familyMapApiProvider).load());
  }
}
