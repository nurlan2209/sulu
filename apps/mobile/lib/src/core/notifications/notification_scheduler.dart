import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_api.dart';

abstract class NotificationScheduler {
  Future<void> sync({
    required String token,
    required String titleBehind,
    required String bodyBehind,
    required String titleLongTime,
    required String bodyLongTime,
  });
}

class NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> sync({
    required String token,
    required String titleBehind,
    required String bodyBehind,
    required String titleLongTime,
    required String bodyLongTime,
  }) async {
    return;
  }
}

class LocalNotificationScheduler implements NotificationScheduler {
  static const _channelId = 'damu_water';
  static const _channelName = 'Water reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationApi _api;
  bool _initialized = false;

  LocalNotificationScheduler(this._plugin, this._api);

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(init);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(_channelId, _channelName, importance: Importance.defaultImportance),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  @override
  Future<void> sync({
    required String token,
    required String titleBehind,
    required String bodyBehind,
    required String titleLongTime,
    required String bodyLongTime,
  }) async {
    await init();
    await requestPermissions();

    final items = await _api.recommendations(token);
    await _plugin.cancelAll();

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final (title, body) = switch (item.type) {
        'behind_schedule' => (titleBehind, bodyBehind),
        'long_time_no_drink' => (titleLongTime, bodyLongTime),
        _ => (titleLongTime, bodyLongTime),
      };

      final when = tz.TZDateTime.from(item.fireAt, tz.local);
      if (when.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        10_000 + i,
        title,
        body,
        when,
        NotificationDetails(
          android: AndroidNotificationDetails(_channelId, _channelName),
          iOS: const DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('Scheduled ${items.length} notification(s)');
    }
  }
}

final notificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) => FlutterLocalNotificationsPlugin());

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  if (kIsWeb) return NoopNotificationScheduler();
  if (defaultTargetPlatform != TargetPlatform.iOS) return NoopNotificationScheduler();
  return LocalNotificationScheduler(ref.watch(notificationsPluginProvider), ref.watch(notificationApiProvider));
});
