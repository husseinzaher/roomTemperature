import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/auth_error_text.dart';
import 'package:auth_presentation/src/cubit/sign_up_cubit.dart';
import 'package:auth_presentation/src/cubit/sign_up_state.dart';
import 'package:auth_presentation/src/widgets/auth_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template sign_up_page}
/// The sign-up page: email/password account creation.
/// {@endtemplate}
class SignUpPage extends StatelessWidget {
  /// {@macro sign_up_page}
  const SignUpPage({
    required this.onNavigateToLogin,
    super.key,
  });

  /// Called when the user asks to go back to the login page.
  final VoidCallback onNavigateToLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(context.read<SignUpCommand>()),
      child: _SignUpView(onNavigateToLogin: onNavigateToLogin),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView({required this.onNavigateToLogin});

  final VoidCallback onNavigateToLogin;

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      context.read<SignUpCubit>().submit(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
              child: BlocBuilder<SignUpCubit, SignUpState>(
                builder: (context, state) {
                  final isSubmitting = state.status == SignUpStatus.submitting;
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
                        l10n.createAccount,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (state.status == SignUpStatus.failure) ...[
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
                      const SizedBox(height: 16),
                      AppTextField(
                        labelText: l10n.password,
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        labelText: l10n.confirmPassword,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: l10n.signUp,
                        isLoading: isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount),
                          TextButton(
                            onPressed: isSubmitting
                                ? null
                                : widget.onNavigateToLogin,
                            child: Text(l10n.login),
                          ),
                        ],
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
