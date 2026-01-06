class User {
  final String id;
  final String fullName;
  final String email;
  final int? weightKg;
  final int? dailyWaterGoal;
  final String language; // kz/ru
  final String? timezone;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dailyWaterGoal,
    required this.language,
    required this.weightKg,
    required this.timezone,
    required this.avatarUrl,
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
    );
  }

  User copyWith({
    String? fullName,
    int? weightKg,
    int? dailyWaterGoal,
    String? language,
    String? timezone,
    String? avatarUrl,
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
    );
  }
}
