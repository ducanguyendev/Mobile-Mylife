import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_anniversary.dart';
import '../services/anniversary_api_service.dart';

final anniversaryProvider =
    AsyncNotifierProvider<AnniversaryNotifier, List<FamilyAnniversary>>(
        AnniversaryNotifier.new);

class AnniversaryNotifier extends AsyncNotifier<List<FamilyAnniversary>> {
  @override
  Future<List<FamilyAnniversary>> build() =>
      ref.read(anniversaryApiProvider).list();
  Future<void> refresh() async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => ref.read(anniversaryApiProvider).list());
  }

  Future<void> save(FamilyAnniversary event) async {
    await ref.read(anniversaryApiProvider).save(event);
    await refresh();
  }

  Future<void> delete(int id) async {
    await ref.read(anniversaryApiProvider).delete(id);
    await refresh();
  }
}
