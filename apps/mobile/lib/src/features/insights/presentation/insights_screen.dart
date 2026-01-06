import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/damu_colors.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import 'insights_controller.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final text = ref.watch(insightsControllerProvider);

    return Container(
      color: DamuColors.lightBg,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Text(t.insightsTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2B5C8A))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: text.when(
              data: (v) => Text(v.isEmpty ? t.emptyValue : v, style: const TextStyle(fontSize: 16)),
              error: (e, _) => Text(e.toString()),
              loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
            ),
          ),
        ],
      ),
    );
  }
}

