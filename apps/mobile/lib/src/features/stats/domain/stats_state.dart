class StatsState {
  final Map<String, dynamic> weekly;
  final Map<String, dynamic> monthly;
  final String selectedMonth; // YYYY-MM

  const StatsState({required this.weekly, required this.monthly, required this.selectedMonth});

  StatsState copyWith({Map<String, dynamic>? weekly, Map<String, dynamic>? monthly, String? selectedMonth}) {
    return StatsState(
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

