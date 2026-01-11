import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_scheduler.dart';
import '../../../ui/damu_colors.dart';
import '../../../ui/damu_text_styles.dart';
import '../../../ui/damu_widgets.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';
import '../../auth/domain/session.dart';
import '../presentation/water_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _lastSyncedToken;
  late final ProviderSubscription<AsyncValue<Session?>> _sessionSub;

  @override
  void initState() {
    super.initState();
    _sessionSub = ref.listenManual(
      sessionControllerProvider,
      (_, next) {
        final session = next.valueOrNull;
        if (session == null) {
          _lastSyncedToken = null;
          return;
        }
        _scheduleSync(session.token);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _sessionSub.close();
    super.dispose();
  }

  void _scheduleSync(String token) {
    if (_lastSyncedToken == token) return;
    _lastSyncedToken = token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncNotifications(token);
    });
  }

  Future<void> _syncNotifications(String token) async {
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    if (t == null) return;
    await ref.read(notificationSchedulerProvider).sync(
          token: token,
          titleBehind: t.behindScheduleTitle,
          bodyBehind: t.behindScheduleBody,
          titleLongTime: t.longTimeNoDrinkTitle,
          bodyLongTime: t.longTimeNoDrinkBody,
        );
  }

  Future<void> _addWaterAndSync(int amount) async {
    await ref.read(waterControllerProvider.notifier).addWater(amount: amount);
    if (!mounted) return;
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null) return;
    await _syncNotifications(session.token);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final progress = ref.watch(waterControllerProvider);
    final isBusy = progress.isLoading;
    final notificationSettings = session?.user.notificationSettings;
    final intervalMinutes = notificationSettings?.intervalMinutes ?? 90;
    final quietStart = notificationSettings?.quietHours.start ?? '22:00';
    final quietEnd = notificationSettings?.quietHours.end ?? '08:00';
    final streakDays = session?.user.streak ?? 0;
    final historyLogs = progress.maybeWhen(data: (p) => p.logs, orElse: () => const []);
    final visibleHistory = historyLogs.length > 3 ? historyLogs.sublist(historyLogs.length - 3) : historyLogs;
    void openReminderSettings() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const _ReminderSettingsSheet(),
      );
    }

    final bottomGap = 72.0 + MediaQuery.paddingOf(context).bottom;
    return Container(
      color: DamuColors.lightBg,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomGap),
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
              data: (p) => DamuWaterTank(size: 280, percent: p.percent),
              loading: () => const DamuWaterTank(size: 280, percent: 0),
              error: (_, __) => const DamuWaterTank(size: 280, percent: 0),
            ),
          ),
          const SizedBox(height: 18),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 160,
            ),
            children: [
              _HomeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(icon: Icons.flash_on_rounded, title: t.quickAddTitle, maxLines: 2),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickAddButton(amount: 200, onTap: isBusy ? null : () => _addWaterAndSync(200)),
                            _QuickAddButton(amount: 250, onTap: isBusy ? null : () => _addWaterAndSync(250)),
                            _QuickAddButton(amount: 500, onTap: isBusy ? null : () => _addWaterAndSync(500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _HomeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(icon: Icons.schedule, title: t.historyTitle),
                    const SizedBox(height: 10),
                    if (visibleHistory.isEmpty)
                      Text(
                        t.historyEmpty,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF8B98A1)),
                      )
                    else
                      for (var i = 0; i < visibleHistory.length; i++) ...[
                        _HistoryRow(time: visibleHistory[i].time, amount: visibleHistory[i].amount),
                        if (i != visibleHistory.length - 1) const SizedBox(height: 8),
                      ],
                  ],
                ),
              ),
              _HomeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(icon: Icons.emoji_events_outlined, title: t.challengeTitle),
                    const Spacer(),
                    Text(t.challengeSubtitle, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E4E70))),
                    const SizedBox(height: 6),
                    Text(
                      t.challengeStreak(streakDays.toString()),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2CA3C0)),
                    ),
                  ],
                ),
              ),
              _HomeCard(
                onTap: openReminderSettings,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(icon: Icons.notifications_none, title: t.reminderSettingsButton),
                    const Spacer(),
                    Text(
                      t.reminderSettingsIntervalValue(intervalMinutes.toString()),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E4E70)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${t.reminderSettingsQuietHoursLabel}: $quietStart–$quietEnd',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF8B98A1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(color: DamuColors.primarySoft, borderRadius: BorderRadius.circular(18)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text('$consumed/$goal ml', style: DamuTextStyles.pillValue()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('$percent%', style: DamuTextStyles.pillPercent()),
              ),
            ),
          ],
        ),
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

class _HomeCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _HomeCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int maxLines;
  const _CardHeader({required this.icon, required this.title, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2CA3C0)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E4E70)),
          ),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final VoidCallback? onTap;
  const _QuickAddButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2CA3C0),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('+$amount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const Text('ml', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String time;
  final int amount;
  const _HistoryRow({required this.time, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E4E70))),
        Text(
          '$amount ml',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7E8CA0)),
        ),
      ],
    );
  }
}

const int _kIntervalMin = 15;
const int _kIntervalMax = 360;
const int _kIntervalStep = 15;

class _ReminderSettingsSheet extends ConsumerStatefulWidget {
  const _ReminderSettingsSheet();

  @override
  ConsumerState<_ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends ConsumerState<_ReminderSettingsSheet> {
  late bool _enabled;
  late int _intervalMinutes;
  late TimeOfDay _quietStart;
  late TimeOfDay _quietEnd;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider).valueOrNull;
    final settings = session?.user.notificationSettings;
    _enabled = settings?.enabled ?? true;
    _intervalMinutes = settings?.intervalMinutes ?? 90;
    _quietStart = _parseTimeOfDay(settings?.quietHours.start) ?? const TimeOfDay(hour: 22, minute: 0);
    _quietEnd = _parseTimeOfDay(settings?.quietHours.end) ?? const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: _quietStart);
    if (picked != null && mounted) setState(() => _quietStart = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: _quietEnd);
    if (picked != null && mounted) setState(() => _quietEnd = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null) return;
    final t = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref.read(sessionControllerProvider.notifier).patchMe({
        'notificationSettings': {
          'enabled': _enabled,
          'intervalMinutes': _intervalMinutes,
          'quietHours': {
            'start': _formatTimeOfDay(_quietStart),
            'end': _formatTimeOfDay(_quietEnd),
          },
        }
      });
      if (!mounted) return;
      await ref.read(notificationSchedulerProvider).sync(
            token: session.token,
            titleBehind: t.behindScheduleTitle,
            bodyBehind: t.behindScheduleBody,
            titleLongTime: t.longTimeNoDrinkTitle,
            bodyLongTime: t.longTimeNoDrinkBody,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomInset + 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.reminderSettingsTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text(t.reminderSettingsEnabled, style: const TextStyle(fontWeight: FontWeight.w600))),
                Switch.adaptive(value: _enabled, onChanged: _saving ? null : (v) => setState(() => _enabled = v)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.reminderSettingsIntervalLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  t.reminderSettingsIntervalValue(_intervalMinutes.toString()),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2CA3C0)),
                ),
              ],
            ),
            Slider(
              value: _intervalMinutes.toDouble(),
              min: _kIntervalMin.toDouble(),
              max: _kIntervalMax.toDouble(),
              divisions: (_kIntervalMax - _kIntervalMin) ~/ _kIntervalStep,
              onChanged: !_enabled || _saving ? null : (v) => setState(() => _intervalMinutes = v.round()),
              activeColor: const Color(0xFF2CA3C0),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.reminderSettingsQuietHoursLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: !_enabled || _saving ? null : _pickStart,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD5DADD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(t.reminderSettingsQuietStart(_formatTimeOfDay(_quietStart))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: !_enabled || _saving ? null : _pickEnd,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD5DADD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(t.reminderSettingsQuietEnd(_formatTimeOfDay(_quietEnd))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CA3C0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(t.saveButton, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TimeOfDay? _parseTimeOfDay(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
}

String _formatTimeOfDay(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
