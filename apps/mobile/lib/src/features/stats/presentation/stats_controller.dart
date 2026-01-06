import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stats_api.dart';
import '../domain/stats_state.dart';

final statsControllerProvider = AsyncNotifierProvider<StatsController, StatsState>(StatsController.new);

class StatsController extends AsyncNotifier<StatsState> {
  String _selectedMonth = _monthKey(DateTime.now());

  @override
  Future<StatsState> build() async {
    final api = ref.read(statsApiProvider);
    final weekly = api.weekly();
    final monthly = api.monthly(month: _selectedMonth);
    final results = await Future.wait([weekly, monthly]);
    return StatsState(weekly: results[0], monthly: results[1], selectedMonth: _selectedMonth);
  }

  Future<void> setMonth(String monthKey) async {
    _selectedMonth = monthKey;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final prev = state.valueOrNull;
      final monthly = await ref.read(statsApiProvider).monthly(month: _selectedMonth);
      if (prev == null) {
        final weekly = await ref.read(statsApiProvider).weekly();
        return StatsState(weekly: weekly, monthly: monthly, selectedMonth: _selectedMonth);
      }
      return prev.copyWith(monthly: monthly, selectedMonth: _selectedMonth);
    });
  }
}

String _monthKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$y-$m';
}
