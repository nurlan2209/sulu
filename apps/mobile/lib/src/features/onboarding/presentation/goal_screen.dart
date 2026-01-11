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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                t.goalTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 26),
              _WeightRuler(
                weight: _weight,
                onChanged: busy ? null : (v) => setState(() => _weight = v),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: OutlinedButton(
                        onPressed: busy ? null : () => Navigator.of(context).maybePop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD5DADD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A4A4A), size: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 64,
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
                            backgroundColor: const Color(0xFF2CA3C0),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.finishButton),
                              const SizedBox(width: 12),
                              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.65)),
                              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4)),
                              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.25)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const int _kMinWeight = 40;
const int _kMaxWeight = 150;
const int _kWindowSize = 40;
const int _kMinorStep = 2;
const int _kMajorStep = 10;
const double _kPixelsPerKg = 10;

class _WeightRuler extends StatelessWidget {
  final double weight;
  final ValueChanged<double>? onChanged;
  const _WeightRuler({required this.weight, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DamuColors.lightBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(weight.round().toString(), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 18),
          SizedBox(
            height: 70,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RulerPainter(value: weight),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: onChanged == null
                        ? null
                        : (details) {
                            final next = (weight + details.delta.dx / _kPixelsPerKg)
                                .clamp(_kMinWeight.toDouble(), _kMaxWeight.toDouble());
                            onChanged!(next.roundToDouble());
                          },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
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
    final major = Paint()
      ..color = const Color(0xFF6F7F86)
      ..strokeWidth = 2;
    final minor = Paint()
      ..color = const Color(0xFFB8C3CA)
      ..strokeWidth = 1;
    final pointer = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    final window = _kWindowSize.toDouble();
    var displayMin = value - window / 2;
    var displayMax = value + window / 2;
    if (displayMin < _kMinWeight) {
      displayMin = _kMinWeight.toDouble();
      displayMax = displayMin + window;
    }
    if (displayMax > _kMaxWeight) {
      displayMax = _kMaxWeight.toDouble();
      displayMin = displayMax - window;
    }

    final baseline = size.height - 18;
    final range = displayMax - displayMin;
    final start = displayMin.ceil();
    final end = displayMax.floor();
    for (var v = start; v <= end; v++) {
      final isMajor = v % _kMajorStep == 0;
      final isMinor = v % _kMinorStep == 0;
      if (!isMajor && !isMinor) continue;
      final x = ((v - displayMin) / range) * size.width;
      final h = isMajor ? 24.0 : 12.0;
      canvas.drawLine(Offset(x, baseline), Offset(x, baseline - h), isMajor ? major : minor);
      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(
            text: v.toString(),
            style: const TextStyle(color: Color(0xFF8B98A1), fontSize: 22, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 0));
      }
    }

    final t = ((value - displayMin) / range).clamp(0.0, 1.0);
    final cx = t * size.width;
    canvas.drawLine(Offset(cx, baseline), Offset(cx, baseline - 26), pointer);
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => oldDelegate.value != value;
}
