import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/damu_colors.dart';
import '../../../../ui/damu_text_styles.dart';
import '../../../../ui/damu_widgets.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../session_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      backgroundColor: DamuColors.startBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(t.appTitle, style: DamuTextStyles.title()),
                  const SizedBox(height: 14),
                  Container(
                    width: 120,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 12, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        DamuTextField(controller: _email, hint: t.emailHint, prefixIcon: Icons.mail_outline),
                        const SizedBox(height: 14),
                        DamuTextField(controller: _password, hint: t.passwordHint, prefixIcon: Icons.lock_outline, obscure: true),
                        const SizedBox(height: 22),
                        DamuPillButton(
                          text: t.loginButton,
                          onPressed: session.isLoading
                              ? null
                              : () async {
                                  await ref.read(sessionControllerProvider.notifier).login(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                      );
                                },
                          background: DamuColors.primary,
                          foreground: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        DamuPillButton(
                          text: t.registerButton,
                          onPressed: () => context.go('/auth/register'),
                          background: const Color(0xFFD9D9D9),
                          foreground: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
