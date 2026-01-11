class HydrationProgress {
  final int consumed;
  final int goal;
  final int percent;
  final List<WaterLogEntry> logs;

  const HydrationProgress({required this.consumed, required this.goal, required this.percent, required this.logs});

  factory HydrationProgress.fromJson(Map<String, dynamic> json) {
    final logsJson = (json['logs'] as List<dynamic>? ?? const []);
    return HydrationProgress(
      consumed: (json['consumed'] as num).toInt(),
      goal: (json['goal'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num).toInt(),
      logs: logsJson
          .map((e) => (e as Map).cast<String, dynamic>())
          .map((e) => WaterLogEntry.fromJson(e))
          .toList(growable: false),
    );
  }
}

class WaterLogEntry {
  final String time;
  final int amount;

  const WaterLogEntry({required this.time, required this.amount});

  factory WaterLogEntry.fromJson(Map<String, dynamic> json) {
    return WaterLogEntry(
      time: (json['time'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}
