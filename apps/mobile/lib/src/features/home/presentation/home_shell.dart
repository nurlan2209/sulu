import 'package:flutter/material.dart';
import '../../../ui/damu_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../auth/presentation/session_controller.dart';

import '../../stats/presentation/stats_screen.dart';
import '../../insights/presentation/insights_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'home_screen.dart';
import 'water_controller.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [HomeScreen(), StatsScreen(), SizedBox.shrink(), InsightsScreen(), ProfileScreen()];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _ShellBackground(index: _index),
          SafeArea(child: pages[_index]),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onChanged: (i) {
          if (i == 2) {
            _openAddWaterSheet(context);
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }

  Future<void> _openAddWaterSheet(BuildContext context) async {
    if (_index != 0) setState(() => _index = 0);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _AddWaterSheet(),
    );
  }
}

class _ShellBackground extends StatelessWidget {
  final int index;
  const _ShellBackground({required this.index});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: DamuColors.lightBg),
      child: SizedBox.expand(),
    );
  }
}

class _AddWaterSheet extends ConsumerWidget {
  const _AddWaterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final items = const [100, 200, 250, 500];
    final padding = MediaQuery.viewInsetsOf(context);
    Future<void> addWaterAndSync(int amount) async {
      await ref.read(waterControllerProvider.notifier).addWater(amount: amount);
      final session = ref.read(sessionControllerProvider).valueOrNull;
      if (session == null || !context.mounted) return;
      await ref.read(notificationSchedulerProvider).sync(
            token: session.token,
            titleBehind: t.behindScheduleTitle,
            bodyBehind: t.behindScheduleBody,
            titleLongTime: t.longTimeNoDrinkTitle,
            bodyLongTime: t.longTimeNoDrinkBody,
          );
    }
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: padding.bottom + 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(t.addWaterTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final ml in items)
                  _AmountButton(
                    ml: ml,
                    onTap: () async {
                      await addWaterAndSync(ml);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                _AmountButton(
                  ml: 0,
                  label: t.customAmountButton,
                  onTap: () async {
                    final v = await showDialog<int>(
                      context: context,
                      builder: (_) => const _CustomAmountDialog(),
                    );
                    if (v == null) return;
                    await addWaterAndSync(v);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final int ml;
  final String? label;
  final VoidCallback onTap;
  const _AmountButton({required this.ml, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    final text = label ?? '+$ml ml';
    return SizedBox(
      width: 120,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F7AD8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _CustomAmountDialog extends StatefulWidget {
  const _CustomAmountDialog();

  @override
  State<_CustomAmountDialog> createState() => _CustomAmountDialogState();
}

class _CustomAmountDialogState extends State<_CustomAmountDialog> {
  final _c = TextEditingController(text: '250');

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.customAmountTitle),
      content: TextField(
        controller: _c,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: '250'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancelButton)),
        ElevatedButton(
          onPressed: () {
            final v = int.tryParse(_c.text.trim());
            if (v == null || v <= 0) return;
            Navigator.pop(context, v);
          },
          child: Text(t.okButton),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFF2D9CB5);
    const barShadow = BoxShadow(color: Color(0x26000000), blurRadius: 18, offset: Offset(0, 8));
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [barShadow],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: SizedBox(
                height: 62,
                child: Row(
                  children: [
                    _NavItem(icon: Icons.home_filled, selected: index == 0, onTap: () => onChanged(0), activeColor: barColor),
                    _NavItem(icon: Icons.show_chart, selected: index == 1, onTap: () => onChanged(1), activeColor: barColor),
                    _AddNavItem(onTap: () => onChanged(2), accentColor: barColor),
                    _NavItem(icon: Icons.notifications_none, selected: index == 3, onTap: () => onChanged(3), activeColor: barColor),
                    _NavItem(icon: Icons.person_outline, selected: index == 4, onTap: () => onChanged(4), activeColor: barColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  const _NavItem({required this.icon, required this.selected, required this.onTap, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 220);
    final lift = selected ? 16.0 : 0.0;
    final size = selected ? 52.0 : 40.0;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, -lift),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: selected ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
                border: selected ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3) : null,
                boxShadow: selected ? const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 6))] : null,
              ),
              child: Icon(icon, color: selected ? Colors.white : Colors.white70, size: selected ? 26 : 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final Color accentColor;
  const _AddNavItem({required this.onTap, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
          child: Center(
            child: Transform.translate(
            offset: const Offset(0, 0),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: DamuColors.shadow, blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Icon(Icons.add, color: accentColor, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
