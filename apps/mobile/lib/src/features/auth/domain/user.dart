class User {
  final String id;
  final String fullName;
  final String email;
  final int? weightKg;
  final int? dailyWaterGoal;
  final String language; // kz/ru
  final String? timezone;
  final String? avatarUrl;
  final NotificationSettings notificationSettings;
  final int streak;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dailyWaterGoal,
    required this.language,
    required this.weightKg,
    required this.timezone,
    required this.avatarUrl,
    required this.notificationSettings,
    required this.streak,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      weightKg: (json['weight'] as num?)?.toInt(),
      dailyWaterGoal: (json['dailyWaterGoal'] as num?)?.toInt(),
      language: (json['language'] ?? 'kz').toString(),
      timezone: (json['timezone'] as String?)?.trim().isEmpty == true ? null : json['timezone'] as String?,
      avatarUrl: (json['avatarUrl'] as String?)?.trim().isEmpty == true ? null : json['avatarUrl'] as String?,
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings'] as Map<String, dynamic>?),
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }

  User copyWith({
    String? fullName,
    int? weightKg,
    int? dailyWaterGoal,
    String? language,
    String? timezone,
    String? avatarUrl,
    NotificationSettings? notificationSettings,
    int? streak,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      language: language ?? this.language,
      weightKg: weightKg ?? this.weightKg,
      timezone: timezone ?? this.timezone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      streak: streak ?? this.streak,
    );
  }
}

class NotificationSettings {
  final bool enabled;
  final int intervalMinutes;
  final QuietHours quietHours;

  const NotificationSettings({
    required this.enabled,
    required this.intervalMinutes,
    required this.quietHours,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return NotificationSettings(
      enabled: data['enabled'] as bool? ?? true,
      intervalMinutes: (data['intervalMinutes'] as num?)?.toInt() ?? 90,
      quietHours: QuietHours.fromJson(data['quietHours'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'intervalMinutes': intervalMinutes,
        'quietHours': quietHours.toJson(),
      };

  NotificationSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    QuietHours? quietHours,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

class QuietHours {
  final String start;
  final String end;

  const QuietHours({required this.start, required this.end});

  factory QuietHours.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return QuietHours(
      start: (data['start'] as String?)?.trim().isEmpty == true ? '22:00' : (data['start'] as String?) ?? '22:00',
      end: (data['end'] as String?)?.trim().isEmpty == true ? '08:00' : (data['end'] as String?) ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
      };
}
