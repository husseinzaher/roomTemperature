import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/auth_error_text.dart';
import 'package:auth_presentation/src/cubit/login_cubit.dart';
import 'package:auth_presentation/src/cubit/login_state.dart';
import 'package:auth_presentation/src/widgets/auth_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template login_page}
/// The login page: email/password sign-in.
/// {@endtemplate}
class LoginPage extends StatelessWidget {
  /// {@macro login_page}
  const LoginPage({
    required this.onNavigateToSignUp,
    required this.onNavigateToForgotPassword,
    super.key,
  });

  /// Called when the user asks to go to the sign-up page.
  final VoidCallback onNavigateToSignUp;

  /// Called when the user asks to go to the forgot-password page.
  final VoidCallback onNavigateToForgotPassword;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<SignInCommand>()),
      child: _LoginView(
        onNavigateToSignUp: onNavigateToSignUp,
        onNavigateToForgotPassword: onNavigateToForgotPassword,
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({
    required this.onNavigateToSignUp,
    required this.onNavigateToForgotPassword,
  });

  final VoidCallback onNavigateToSignUp;
  final VoidCallback onNavigateToForgotPassword;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      context.read<LoginCubit>().submit(
        email: _emailController.text,
        password: _passwordController.text,
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
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  final isSubmitting = state.status == LoginStatus.submitting;
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
                        l10n.welcomeBack,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (state.status == LoginStatus.failure) ...[
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : widget.onNavigateToForgotPassword,
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: l10n.login,
                        isLoading: isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.dontHaveAccount),
                          TextButton(
                            onPressed: isSubmitting
                                ? null
                                : widget.onNavigateToSignUp,
                            child: Text(l10n.signUp),
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
