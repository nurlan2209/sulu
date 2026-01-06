import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/damu_colors.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import 'stats_controller.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final stats = ref.watch(statsControllerProvider);

    return Container(
      color: DamuColors.lightBg,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          stats.when(
            data: (s) {
              final items = _itemsFromJson(s.weekly['items']);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DatePickerRow(
                    selected: _selectedDate,
                    onPick: (date) => setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 12),
                  _WeekRangePill(range: _weekRangeText(items)),
                ],
              );
            },
            loading: () => const _WeekRangePill(range: '—'),
            error: (_, __) => const _WeekRangePill(range: '—'),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              t.resultsTitle,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2B5C8A)),
            ),
          ),
          const SizedBox(height: 12),
          stats.when(
            data: (s) {
              final weekly = s.weekly;
              final monthly = s.monthly;
              final items = _itemsFromJson(weekly['items']);
              final selected = _findByDate(items, _selectedDate);
              final weeklyMl = (weekly['avgMlPerDay'] ?? 0).toString();
              final monthlyMl = (monthly['avgMlPerDay'] ?? 0).toString();
              final avgPercent = '${weekly['avgPercent'] ?? 0}%';
              final freq = (weekly['avgDrinksPerDay'] ?? 0).toString();
              return Column(
                children: [
                  SizedBox(height: 220, child: _BarChart(items: items)),
                  const SizedBox(height: 12),
                  _SelectedDayCard(
                    date: _selectedDate,
                    total: selected?['totalIntake'] ?? 0,
                    goal: selected?['goal'] ?? weekly['goal'] ?? 0,
                  ),
                  const SizedBox(height: 12),
                  _SummaryBlock(
                    weekly: t.mlPerDay(weeklyMl),
                    monthly: t.mlPerDay(monthlyMl),
                    avgPercent: avgPercent,
                    freq: t.timesPerDay(freq),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _BarChart({required this.items});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(items: items),
      size: Size.infinite,
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  _BarPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final bars = items.take(7).toList();
    if (bars.isEmpty) return;

    final maxV = bars.fold<double>(1, (m, e) => math.max(m, (e['totalIntake'] as num?)?.toDouble() ?? 0));
    final barPaint = Paint()..color = const Color(0xFF2BA0B9);
    final axis = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1;

    final left = 26.0;
    final bottom = size.height - 30;
    canvas.drawLine(Offset(left, bottom), Offset(size.width - 12, bottom), axis);

    final count = bars.length;
    final gap = 18.0;
    final w = (size.width - left - 18 - gap * (count - 1)) / count;
    final h = bottom - 20;

    final textStyle = const TextStyle(color: Color(0xFF2BA0B9), fontWeight: FontWeight.w700, fontSize: 12);
    for (var i = 0; i < count; i++) {
      final x = left + i * (w + gap);
      final total = (bars[i]['totalIntake'] as num?)?.toDouble() ?? 0;
      final barH = (total / maxV) * h;
      final rect = Rect.fromLTWH(x, bottom - barH, w, barH);
      canvas.drawRect(rect, barPaint);

      final tp = TextPainter(text: TextSpan(text: total.round().toString(), style: textStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x + (w - tp.width) / 2, bottom - barH - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => oldDelegate.items != items;
}

class _SummaryBlock extends StatelessWidget {
  final String weekly;
  final String monthly;
  final String avgPercent;
  final String freq;
  const _SummaryBlock({required this.weekly, required this.monthly, required this.avgPercent, required this.freq});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(t.waterReportTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _RowDot(color: Colors.green, left: t.weeklyReportLabel, right: weekly),
        _RowDot(color: Colors.blue, left: t.monthlyReportLabel, right: monthly),
        _RowDot(color: Colors.orange, left: t.avgCompletionLabel, right: avgPercent),
        _RowDot(color: Colors.red, left: t.drinkFrequencyLabel, right: freq),
      ],
    );
  }
}

class _RowDot extends StatelessWidget {
  final Color color;
  final String left;
  final String right;
  const _RowDot({required this.color, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(left, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Text(right, style: const TextStyle(color: Color(0xFF2BA0B9), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DateTime date;
  final int total;
  final int goal;
  const _SelectedDayCard({required this.date, required this.total, required this.goal});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = goal > 0 ? ((total / goal) * 100).clamp(0, 200).round() : 0;
    final hasData = total > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2B5C8A))),
          const SizedBox(height: 6),
          Text('${t.dailyGoalLabel}: $goal ml', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          hasData
              ? Text('$total ml • $percent%', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2BA0B9)))
              : Text(t.noWaterDayMessage, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF9E3A3A))),
        ],
      ),
    );
  }
}

class _WeekRangePill extends StatelessWidget {
  final String range;
  const _WeekRangePill({required this.range});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Text(range, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2F7AD8))),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  const _DatePickerRow({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2F7AD8)),
                const SizedBox(width: 10),
                Text(_formatDate(selected), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2F7AD8))),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final first = now.subtract(const Duration(days: 6));
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selected.isAfter(now) ? now : selected,
                      firstDate: first,
                      lastDate: now,
                    );
                    if (picked != null) onPick(picked);
                  },
                  icon: const Icon(Icons.edit_calendar, color: Color(0xFF4B647F)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<Map<String, dynamic>> _itemsFromJson(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

Map<String, dynamic>? _findByDate(List<Map<String, dynamic>> items, DateTime date) {
  final key = _formatKey(date);
  try {
    return items.firstWhere((e) => e['date'] == key);
  } catch (_) {
    return null;
  }
}

String _formatKey(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

String _formatDate(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

String _weekRangeText(List<Map<String, dynamic>> items) {
  if (items.isEmpty) return '—';
  DateTime? min, max;
  for (final e in items) {
    final d = e['date']?.toString();
    if (d == null || d.isEmpty) continue;
    try {
      final dt = DateTime.parse(d);
      min = min == null || dt.isBefore(min) ? dt : min;
      max = max == null || dt.isAfter(max) ? dt : max;
    } catch (_) {}
  }
  if (min == null || max == null) return '—';
  String fmt(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  return '${fmt(min)} – ${fmt(max)}';
}
