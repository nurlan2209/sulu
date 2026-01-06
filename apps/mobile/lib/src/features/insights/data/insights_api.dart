import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/session_controller.dart';

class InsightsApi {
  final ApiClient _api;
  final Ref _ref;
  InsightsApi(this._api, this._ref);

  Future<Map<String, dynamic>> today() async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    return _api.getJson('/insights/today', token: session?.token);
  }
}

final insightsApiProvider = Provider<InsightsApi>((ref) => InsightsApi(ref.watch(apiClientProvider), ref));
