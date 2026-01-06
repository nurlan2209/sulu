import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/session_controller.dart';
import '../domain/hydration_progress.dart';

class WaterApi {
  final ApiClient _api;
  final Ref _ref;
  WaterApi(this._api, this._ref);

  Future<HydrationProgress> today({String? token}) async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    final json = await _api.getJson('/water/today', token: token ?? session?.token);
    return HydrationProgress.fromJson(json);
  }

  Future<HydrationProgress> add({required int amount, int? temperature}) async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    final json = await _api.postJson('/water/add', token: session?.token, body: {'amount': amount, 'temperature': temperature});
    return HydrationProgress.fromJson(json);
  }
}

final waterApiProvider = Provider<WaterApi>((ref) => WaterApi(ref.watch(apiClientProvider), ref));
