import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/session_controller.dart';

class StatsApi {
  final ApiClient _api;
  final Ref _ref;
  StatsApi(this._api, this._ref);

  Future<Map<String, dynamic>> weekly() async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    return _api.getJson('/stats/weekly', token: session?.token);
  }

  Future<Map<String, dynamic>> monthly({String? month}) async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    final q = month == null ? '' : '?month=$month';
    return _api.getJson('/stats/monthly$q', token: session?.token);
  }
}

final statsApiProvider = Provider<StatsApi>((ref) => StatsApi(ref.watch(apiClientProvider), ref));
