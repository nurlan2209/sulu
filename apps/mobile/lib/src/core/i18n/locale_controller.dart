import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';

Locale _toLocale(String language) {
  switch (language) {
    case 'kz':
      return const Locale('kk');
    case 'ru':
      return const Locale('ru');
    default:
      return const Locale('kk');
  }
}

String _toLanguageCode(Locale locale) {
  if (locale.languageCode == 'kk') return 'kz';
  if (locale.languageCode == 'ru') return 'ru';
  return 'kz';
}

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref);
});

class LocaleController extends StateNotifier<Locale?> {
  static const _key = 'damu.language';
  final Ref _ref;
  LocaleController(this._ref) : super(const Locale('kk')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = _ref.read(sharedPrefsProvider);
    final lang = prefs.getString(_key);
    if (lang != null && lang.isNotEmpty) state = _toLocale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.setString(_key, _toLanguageCode(locale));
  }
}
