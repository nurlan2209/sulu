import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _obscure = true;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                Text(
                  t.loginTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
                ),
                const SizedBox(height: 6),
                Text(
                  t.loginSubtitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF9AA0A6)),
                ),
                const SizedBox(height: 36),
                _AuthField(
                  controller: _email,
                  hint: t.emailHint,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                _AuthField(
                  controller: _password,
                  hint: t.passwordHint,
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA0A6)),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: session.isLoading
                        ? null
                        : () async {
                            await ref.read(sessionControllerProvider.notifier).login(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CA3C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.6),
                    ),
                    child: Text(t.loginButton.toUpperCase()),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/auth/forgot', extra: _email.text.trim()),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF2CA3C0)),
                    child: Text(t.forgotPasswordButton),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.createAccountPrompt, style: const TextStyle(color: Color(0xFF6C7885), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => context.go('/auth/register'),
                      child: Text(
                        t.registerButton,
                        style: const TextStyle(color: Color(0xFF2CA3C0), fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
          prefixIcon: Icon(icon, color: const Color(0xFF2CA3C0)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}
