import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/auth_api.dart';
import '../session_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? prefillEmail;
  const ForgotPasswordScreen({super.key, this.prefillEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _sendingEmail = false;
  bool _resetting = false;
  bool _emailSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    if ((widget.prefillEmail ?? '').isNotEmpty) {
      _email.text = widget.prefillEmail!;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
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
                const SizedBox(height: 96),
                Text(
                  t.forgotPasswordTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
                ),
                const SizedBox(height: 6),
                Text(
                  t.forgotPasswordEnterEmail,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF9AA0A6)),
                ),
                const SizedBox(height: 28),
                _AuthField(
                  controller: _email,
                  hint: t.emailHint,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sendingEmail ? null : () => _sendEmail(t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CA3C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.4),
                    ),
                    child: Text(_emailSent ? t.forgotPasswordResendButton : t.forgotPasswordSendButton),
                  ),
                ),
                const SizedBox(height: 10),
                if (_emailSent)
                  Text(
                    t.forgotPasswordSent,
                    style: const TextStyle(color: Color(0xFF6C7885), fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 22),
                Text(
                  t.forgotPasswordSubtitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2A2A2A)),
                ),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _token,
                  hint: t.resetTokenHint,
                  icon: Icons.vpn_key_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _AuthField(
                  controller: _password,
                  hint: t.newPasswordHint,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA0A6)),
                  ),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: session.isLoading || _resetting ? null : () => _resetPassword(t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CA3C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.4),
                    ),
                    child: Text(t.resetPasswordButton),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/auth/login'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF2CA3C0)),
                    child: Text(t.backToLoginButton),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmail(AppLocalizations t) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    if (email.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t.forgotPasswordEnterEmail)));
      return;
    }
    setState(() => _sendingEmail = true);
    try {
      await ref.read(authApiProvider).forgotPassword(email: email);
      setState(() => _emailSent = true);
      messenger.showSnackBar(SnackBar(content: Text(t.forgotPasswordSent)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.forgotPasswordFailed)));
    } finally {
      if (mounted) setState(() => _sendingEmail = false);
    }
  }

  Future<void> _resetPassword(AppLocalizations t) async {
    final messenger = ScaffoldMessenger.of(context);
    final token = _token.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;
    if (token.isEmpty || password.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t.resetFormIncomplete)));
      return;
    }
    if (password != confirm) {
      messenger.showSnackBar(SnackBar(content: Text(t.passwordsDoNotMatch)));
      return;
    }

    setState(() => _resetting = true);
    try {
      await ref.read(sessionControllerProvider.notifier).resetPassword(token: token, password: password);
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.resetSuccess)));
        context.go('/home');
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.forgotPasswordFailed)));
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
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
