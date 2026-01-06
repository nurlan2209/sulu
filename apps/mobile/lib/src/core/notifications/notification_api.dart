import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

typedef NotificationItem = ({String type, DateTime fireAt});

class NotificationApi {
  final ApiClient _api;
  NotificationApi(this._api);

  Future<List<NotificationItem>> recommendations(String token) async {
    final json = await _api.getJson('/notifications/recommendations', token: token);
    final items = (json['items'] as List<dynamic>? ?? const []);
    return items
        .map((e) => (e as Map).cast<String, dynamic>())
        .map((e) => (type: e['type'].toString(), fireAt: DateTime.parse(e['fireAt'].toString()).toLocal()))
        .toList(growable: false);
  }
}

final notificationApiProvider = Provider<NotificationApi>((ref) => NotificationApi(ref.watch(apiClientProvider)));

