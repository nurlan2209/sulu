import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs.dart';

class TokenStorage {
  static const _key = 'damu.jwt';
  final FlutterSecureStorage? _secure;
  final SharedPreferences? _prefs;

  const TokenStorage.secure(this._secure) : _prefs = null;
  const TokenStorage.prefs(this._prefs) : _secure = null;

  Future<String?> read() async {
    final prefs = _prefs;
    if (prefs != null) return prefs.getString(_key);
    return _secure?.read(key: _key);
  }

  Future<void> write(String token) async {
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_key, token);
      return;
    }
    await _secure?.write(key: _key, value: token);
  }

  Future<void> delete() async {
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.remove(_key);
      return;
    }
    await _secure?.delete(key: _key);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  if (kIsWeb) return TokenStorage.prefs(ref.watch(sharedPrefsProvider));
  return const TokenStorage.secure(FlutterSecureStorage());
});
