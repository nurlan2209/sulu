import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/locale_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../data/user_api.dart';
import '../domain/session.dart';

final sessionControllerProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

class SessionController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await ref.read(userApiProvider).me(token);
      _syncLocaleFromUser(user.language);
      return Session(token: token, user: user);
    } catch (_) {
      await ref.read(tokenStorageProvider).delete();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authApiProvider).login(email: email, password: password);
      final token = result.$1;
      final user = result.$2;
      await ref.read(tokenStorageProvider).write(token);
      _syncLocaleFromUser(user.language);
      return Session(token: token, user: user);
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String language = 'kz',
    String? timezone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authApiProvider).register(
            fullName: fullName,
            email: email,
            password: password,
            language: language,
            timezone: timezone,
          );
      final token = result.$1;
      final user = result.$2;
      await ref.read(tokenStorageProvider).write(token);
      _syncLocaleFromUser(user.language);
      return Session(token: token, user: user);
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).delete();
    state = const AsyncData(null);
  }

  Future<void> updateLanguage(String language) async {
    await patchMe({'language': language});
  }

  Future<void> patchMe(Map<String, dynamic> patch) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final next = await ref.read(userApiProvider).patchMe(current.token, patch);
      _syncLocaleFromUser(next.language);
      return Session(token: current.token, user: next);
    });
  }

  Future<void> patchProfileWeight(int weightKg) async {
    final goal = weightKg * 30;
    await patchMe({'weight': weightKg, 'dailyWaterGoal': goal, 'recalculateGoal': true});
  }

  Future<void> uploadAvatar({required Uint8List bytes, required String filename, required String mime}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref.read(userApiProvider).uploadAvatar(current.token, bytes: bytes, filename: filename, mime: mime);
      return Session(token: current.token, user: updated);
    });
  }

  void _syncLocaleFromUser(String language) {
    final locale = language == 'ru' ? const Locale('ru') : const Locale('kk');
    unawaited(ref.read(localeControllerProvider.notifier).setLocale(locale));
  }
}
