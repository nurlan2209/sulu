import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/damu_colors.dart';
import '../../../ui/damu_text_styles.dart';
import '../../../ui/damu_widgets.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';
import '../presentation/water_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final progress = ref.watch(waterControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F7FF), Color(0xFFE1EDFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(session?.user.fullName ?? '', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(session?.user.email ?? '', style: const TextStyle(color: Color(0xFF1E4E70), fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              const SizedBox(width: 10),
              DamuAvatar(
                url: session?.user.avatarUrl,
                name: session?.user.fullName,
                size: 46,
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: progress.when(
              data: (p) => _ProgressPill(consumed: p.consumed, goal: p.goal, percent: p.percent),
              loading: () => const _ProgressPill(consumed: 0, goal: 0, percent: 0),
              error: (_, __) => const _ProgressPill(consumed: 0, goal: 0, percent: 0),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: progress.when(
              data: (p) => Text(
                '${t.dailyGoalLabel}: ${p.goal} ml',
                style: const TextStyle(color: Color(0xFF1E4E70), fontWeight: FontWeight.w700),
              ),
              loading: () => Text(t.dailyGoalLabel, style: const TextStyle(color: Color(0xFF1E4E70), fontWeight: FontWeight.w700)),
              error: (_, __) => Text(t.dailyGoalLabel, style: const TextStyle(color: Color(0xFF1E4E70), fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: progress.when(
              data: (p) => DamuWaterTank(size: 240, percent: p.percent),
              loading: () => const DamuWaterTank(size: 240, percent: 0),
              error: (_, __) => const DamuWaterTank(size: 240, percent: 0),
            ),
          ),
          const SizedBox(height: 20),
          _ActionCard(
            icon: Icons.water_drop,
            text: t.setGoalButton,
            onTap: () => context.go('/onboarding/goal'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final int consumed;
  final int goal;
  final int percent;
  const _ProgressPill({required this.consumed, required this.goal, required this.percent});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pillW = w.clamp(0, 420).toDouble() - 40;
    final fill = (percent / 100).clamp(0.0, 1.0);
    return Container(
      width: pillW,
      height: 56,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: fill,
            child: Container(
              decoration: BoxDecoration(color: DamuColors.primarySoft, borderRadius: BorderRadius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('$consumed/$goal ml', style: DamuTextStyles.pillValue()),
                const Spacer(),
                Text('$percent%', style: DamuTextStyles.pillPercent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: DamuColors.primaryDeep,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 18, offset: Offset(0, 10))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: Icon(icon, color: DamuColors.primaryDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
