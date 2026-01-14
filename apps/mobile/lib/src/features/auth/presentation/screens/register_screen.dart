import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../session_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
                  t.registerTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
                ),
                const SizedBox(height: 6),
                Text(
                  t.registerSubtitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF9AA0A6)),
                ),
                const SizedBox(height: 36),
                _AuthField(
                  controller: _fullName,
                  hint: t.fullNameHint,
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
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
                  textInputAction: TextInputAction.next,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA0A6)),
                  ),
                ),
                const SizedBox(height: 16),
                _AuthField(
                  controller: _confirm,
                  hint: t.confirmPasswordHint,
                  icon: Icons.verified_outlined,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA0A6)),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: session.isLoading
                        ? null
                        : () => _register(t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CA3C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.4),
                    ),
                    child: Text(t.registerButton),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.haveAccountPrompt, style: const TextStyle(color: Color(0xFF6C7885), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => context.go('/auth/login'),
                      child: Text(
                        t.loginButton,
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

  Future<void> _register(AppLocalizations t) async {
    final messenger = ScaffoldMessenger.of(context);
    final password = _password.text;
    final confirm = _confirm.text;
    if (!_meetsPasswordRequirements(password)) {
      messenger.showSnackBar(SnackBar(content: Text(t.passwordRequirements)));
      return;
    }
    if (password != confirm) {
      messenger.showSnackBar(SnackBar(content: Text(t.passwordsDoNotMatch)));
      return;
    }

    await ref.read(sessionControllerProvider.notifier).register(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          password: password,
          confirmPassword: confirm,
        );
    if (!mounted) return;
    final result = ref.read(sessionControllerProvider);
    if (result.hasError) {
      final err = result.error;
      final message = err is ApiException ? err.message : t.registerFailed;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!context.mounted) return;
    context.go('/onboarding/goal');
  }

  bool _meetsPasswordRequirements(String value) {
    if (value.length < 8 || value.length > 128) return false;
    if (!RegExp(r'[A-Z]').hasMatch(value)) return false;
    if (!RegExp(r'\d').hasMatch(value)) return false;
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) return false;
    return true;
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
