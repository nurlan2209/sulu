import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/damu_colors.dart';
import '../../../ui/damu_text_styles.dart';
import '../../../ui/damu_widgets.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: DamuGradients.hero),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 36),
                Text('💧 ${t.appTitle}', style: DamuTextStyles.title()),
                const Spacer(),
                const DamuCatImage(size: 240),
                const Spacer(),
                DamuPillButton(
                  text: t.startButton,
                  onPressed: () => context.go('/auth/login'),
                  background: Colors.white,
                  foreground: DamuColors.primaryDeep,
                  height: 64,
                  radius: 30,
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
