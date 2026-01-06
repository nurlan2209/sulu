import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';
import '../data/water_api.dart';
import '../domain/hydration_progress.dart';

final waterControllerProvider = AsyncNotifierProvider<WaterController, HydrationProgress>(WaterController.new);

class WaterController extends AsyncNotifier<HydrationProgress> {
  @override
  Future<HydrationProgress> build() async {
    final session = await ref.watch(sessionControllerProvider.future);
    if (session == null) {
      throw StateError('Not authenticated');
    }
    return ref.read(waterApiProvider).today(token: session.token);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final session = await ref.watch(sessionControllerProvider.future);
    if (session == null) {
      state = AsyncError(StateError('Not authenticated'), StackTrace.empty);
      return;
    }
    state = await AsyncValue.guard(() => ref.read(waterApiProvider).today(token: session.token));
  }

  Future<void> addWater({required int amount, int? temperature}) async {
    final prev = state.valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(waterApiProvider).add(amount: amount, temperature: temperature));
    if (state.hasError && prev != null) state = AsyncData(prev);
  }
}
