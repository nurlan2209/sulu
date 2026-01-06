import 'package:flutter/material.dart';
import '../../../ui/damu_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';

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
      body: SafeArea(child: pages[_index]),
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

class _AddWaterSheet extends ConsumerWidget {
  const _AddWaterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final items = const [100, 200, 250, 500];
    final padding = MediaQuery.viewInsetsOf(context);
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
                      await ref.read(waterControllerProvider.notifier).addWater(amount: ml);
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
                    await ref.read(waterControllerProvider.notifier).addWater(amount: v);
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
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: DamuColors.lightBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavIcon(icon: Icons.home_filled, selected: index == 0, onTap: () => onChanged(0)),
                _NavIcon(icon: Icons.show_chart, selected: index == 1, onTap: () => onChanged(1)),
                const SizedBox(width: 44),
                _NavIcon(icon: Icons.notifications_none, selected: index == 3, onTap: () => onChanged(3)),
                _NavIcon(icon: Icons.person_outline, selected: index == 4, onTap: () => onChanged(4)),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
            child: GestureDetector(
              onTap: () => onChanged(2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF7E8CA0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: selected ? const Color(0xFF4B647F) : const Color(0x994B647F),
      ),
    );
  }
}
