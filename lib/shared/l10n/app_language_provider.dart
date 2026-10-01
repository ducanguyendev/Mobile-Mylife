import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage_service.dart';
import 'app_strings.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final storage = ref.watch(tokenStorageServiceProvider);
  return LanguageNotifier(storage);
});

class LanguageNotifier extends StateNotifier<String> {
  final TokenStorageService _storage;

  LanguageNotifier(this._storage) : super('vi') {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final lang = await _storage.getLanguage();
    if (lang != null && (lang == 'vi' || lang == 'en')) {
      state = lang;
    }
  }

  Future<void> setLanguage(String lang) async {
    if (lang == 'vi' || lang == 'en') {
      state = lang;
      await _storage.saveLanguage(lang);
    }
  }

  Future<void> toggleLanguage() async {
    final newLang = state == 'vi' ? 'en' : 'vi';
    state = newLang;
    await _storage.saveLanguage(newLang);
  }

  String tr(String key) {
    return AppStrings.get(key, state);
  }
}
