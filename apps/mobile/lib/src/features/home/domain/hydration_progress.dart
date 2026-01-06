class HydrationProgress {
  final int consumed;
  final int goal;
  final int percent;

  const HydrationProgress({required this.consumed, required this.goal, required this.percent});

  factory HydrationProgress.fromJson(Map<String, dynamic> json) {
    return HydrationProgress(
      consumed: (json['consumed'] as num).toInt(),
      goal: (json['goal'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num).toInt(),
    );
  }
}
