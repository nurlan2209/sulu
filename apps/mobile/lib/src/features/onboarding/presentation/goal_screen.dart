import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/damu_colors.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';
import '../../home/presentation/water_controller.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  double _weight = 70;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final busy = ref.watch(sessionControllerProvider).isLoading;
    final goal = _weight.round() * 30;

    return Scaffold(
      backgroundColor: DamuColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Text(
                t.goalTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 22),
              _WeightRuler(
                weight: _weight.round(),
                onChanged: busy ? null : (v) => setState(() => _weight = v.toDouble()),
              ),
              const SizedBox(height: 12),
              Text(
                t.goalFormula(_weight.round().toString(), goal.toString()),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                t.goalHint(goal.toString()),
                style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final nav = Navigator.of(context);
                          final sessionNotifier = ref.read(sessionControllerProvider.notifier);
                          final waterNotifier = ref.read(waterControllerProvider.notifier);
                          await sessionNotifier.patchProfileWeight(_weight.round());
                          await waterNotifier.refresh();
                          if (nav.mounted) nav.maybePop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BA0B9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: Text(t.finishButton, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightRuler extends StatelessWidget {
  final int weight;
  final ValueChanged<int>? onChanged;
  const _WeightRuler({required this.weight, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF93CBE3),
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        children: [
          Text(weight.toString(), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 10),
          const Text('kg', style: TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: const Color(0xFF2BA0B9),
              inactiveTrackColor: Colors.white54,
            ),
            child: Slider(
              value: weight.toDouble(),
              min: 40,
              max: 150,
              divisions: 110,
              onChanged: onChanged == null ? null : (v) => onChanged!(v.round()),
            ),
          ),
          CustomPaint(
            painter: _RulerPainter(value: weight.toDouble()),
            size: const Size(double.infinity, 46),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double value;
  _RulerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    final tick = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    final min = 40;
    final max = 150;
    final count = max - min;
    final step = size.width / count;
    for (var i = 0; i <= count; i++) {
      final x = i * step;
      final v = min + i;
      final isMajor = v % 10 == 0;
      final h = isMajor ? 22.0 : 12.0;
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - h), isMajor ? p : tick);
      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(text: v.toString(), style: const TextStyle(color: Colors.black45, fontSize: 16, fontWeight: FontWeight.w700)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 0));
      }
    }

    final t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final cx = t * size.width;
    canvas.drawLine(Offset(cx, size.height), Offset(cx, size.height - 30), Paint()..color = Colors.black..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => oldDelegate.value != value;
}
