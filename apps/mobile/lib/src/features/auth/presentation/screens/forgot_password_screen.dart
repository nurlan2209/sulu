import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/damu_colors.dart';
import '../../../../ui/damu_text_styles.dart';
import '../../../../ui/damu_widgets.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(t.forgotPasswordTitle),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DamuGradients.hero),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('🛡️ ${t.appTitle}', style: DamuTextStyles.title()),
                    const SizedBox(height: 12),
                    Text(
                      t.forgotPasswordEnterEmail,
                      style: const TextStyle(color: DamuColors.textMutedLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: DamuGradients.glass,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 16, offset: Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          DamuTextField(controller: _email, hint: t.emailHint, prefixIcon: Icons.mail_outline),
                          const SizedBox(height: 10),
                          DamuPillButton(
                            text: _emailSent ? t.forgotPasswordResendButton : t.forgotPasswordSendButton,
                            onPressed: _sendingEmail ? null : () => _sendEmail(t),
                            background: DamuColors.primaryDeep,
                            foreground: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          if (_emailSent)
                            Text(
                              t.forgotPasswordSent,
                              style: const TextStyle(color: DamuColors.textPrimary),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t.forgotPasswordSubtitle,
                              style: const TextStyle(color: DamuColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DamuTextField(controller: _token, hint: t.resetTokenHint, prefixIcon: Icons.vpn_key_outlined),
                          const SizedBox(height: 12),
                          DamuTextField(controller: _password, hint: t.newPasswordHint, prefixIcon: Icons.lock_outline, obscure: true),
                          const SizedBox(height: 12),
                          DamuTextField(controller: _confirm, hint: t.confirmPasswordHint, prefixIcon: Icons.verified_outlined, obscure: true),
                          const SizedBox(height: 16),
                          DamuPillButton(
                            text: t.resetPasswordButton,
                            onPressed: session.isLoading || _resetting ? null : () => _resetPassword(t),
                            background: Colors.white,
                            foreground: DamuColors.primaryDeep,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => context.go('/auth/login'),
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: Text(t.backToLoginButton),
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
