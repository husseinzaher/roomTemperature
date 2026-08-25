import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/auth_error_text.dart';
import 'package:auth_presentation/src/cubit/forgot_password_cubit.dart';
import 'package:auth_presentation/src/cubit/forgot_password_state.dart';
import 'package:auth_presentation/src/widgets/auth_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template forgot_password_page}
/// The forgot-password page: request a password reset email.
/// {@endtemplate}
class ForgotPasswordPage extends StatelessWidget {
  /// {@macro forgot_password_page}
  const ForgotPasswordPage({
    required this.onNavigateToLogin,
    super.key,
  });

  /// Called when the user asks to go back to the login page.
  final VoidCallback onNavigateToLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(
        context.read<SendPasswordResetCommand>(),
      ),
      child: _ForgotPasswordView(onNavigateToLogin: onNavigateToLogin),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({required this.onNavigateToLogin});

  final VoidCallback onNavigateToLogin;

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      context.read<ForgotPasswordCubit>().submit(
        email: _emailController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  if (state.status == ForgotPasswordStatus.sent) {
                    return _SentView(
                      onNavigateToLogin: widget.onNavigateToLogin,
                    );
                  }

                  final isSubmitting =
                      state.status == ForgotPasswordStatus.submitting;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.thermostat,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.resetPassword,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (state.status == ForgotPasswordStatus.failure) ...[
                        AuthErrorBanner(
                          message: authErrorText(context, state.errorCode),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        labelText: l10n.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: l10n.sendResetLink,
                        isLoading: isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : widget.onNavigateToLogin,
                          child: Text(l10n.login),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  const _SentView({required this.onNavigateToLogin});

  final VoidCallback onNavigateToLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.checkYourEmail,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: l10n.login,
          onPressed: onNavigateToLogin,
        ),
      ],
    );
  }
}
