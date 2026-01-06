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
      backgroundColor: DamuColors.startBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 36),
              Text(t.appTitle, style: DamuTextStyles.title()),
              const Spacer(),
              const DamuCatImage(size: 240),
              const Spacer(),
              SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9AA7FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: Text(t.startButton, style: DamuTextStyles.buttonBig(color: const Color(0xFF9AA7FF))),
                ),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}

