import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/library_models.dart';
import '../services/library_api_service.dart';

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, List<LibraryAlbum>>(
        LibraryNotifier.new);

class LibraryNotifier extends AsyncNotifier<List<LibraryAlbum>> {
  @override
  Future<List<LibraryAlbum>> build() => ref.read(libraryApiProvider).albums();
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(libraryApiProvider).albums());
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(() => ref.read(libraryApiProvider).albums());
  }
}
