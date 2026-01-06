import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/session_controller.dart';

class BadgesApi {
  final ApiClient _api;
  final Ref _ref;
  BadgesApi(this._api, this._ref);

  Future<List<String>> list() async {
    final session = _ref.read(sessionControllerProvider).valueOrNull;
    final json = await _api.getJson('/badges', token: session?.token);
    final list = (json['badges'] as List<dynamic>? ?? const []);
    return list.map((e) => (e as Map)['type'].toString()).toList(growable: false);
  }
}

final badgesApiProvider = Provider<BadgesApi>((ref) => BadgesApi(ref.watch(apiClientProvider), ref));

