import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:room_temperature_app/home/home_shell_page.dart';
import 'package:room_temperature_app/services/debug_auth_repository.dart';
import 'package:room_temperature_app/splash/splash_page.dart';

part 'router.g.dart';

/// The splash route, shown until the app knows whether a user is signed
/// in.
@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  /// Creates a [SplashRoute].
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

/// The login route.
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  /// Creates a [LoginRoute].
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final loginPage = LoginPage(
      onNavigateToSignUp: () => const SignUpRoute().go(context),
      onNavigateToForgotPassword: () => const ForgotPasswordRoute().go(context),
    );

    if (!kDebugMode) return loginPage;

    // Debug-only bypass so the app can be tested before Email/Password
    // sign-in is enabled in the Firebase console. Compiled out of
    // release/profile builds since kDebugMode is a compile-time constant.
    return Stack(
      children: [
        loginPage,
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'debug-skip-auth',
            onPressed: () {
              final authRepository = context.read<IAuthRepository>();
              if (authRepository is DebugAuthRepository) {
                authRepository.debugSignInAsGuest();
              }
            },
            icon: const Icon(Icons.bug_report_outlined),
            label: const Text('Skip (debug)'),
          ),
        ),
      ],
    );
  }
}

/// The sign-up route.
@TypedGoRoute<SignUpRoute>(path: '/signup')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  /// Creates a [SignUpRoute].
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SignUpPage(
      onNavigateToLogin: () => const LoginRoute().go(context),
    );
  }
}

/// The forgot-password route.
@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  /// Creates a [ForgotPasswordRoute].
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ForgotPasswordPage(
      onNavigateToLogin: () => const LoginRoute().go(context),
    );
  }
}

/// The signed-in home route: a bottom-nav shell over the dashboard,
/// history, and settings tabs.
@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  /// Creates a [HomeRoute].
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeShellPage();
  }
}
