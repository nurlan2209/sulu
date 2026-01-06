import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/insights_api.dart';

final insightsControllerProvider = AsyncNotifierProvider<InsightsController, String>(InsightsController.new);

class InsightsController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final json = await ref.read(insightsApiProvider).today();
    final insight = (json['insight'] as Map<String, dynamic>?) ?? const {};
    return (insight['text'] ?? '').toString();
  }
}
