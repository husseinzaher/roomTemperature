import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:room_temperature_app/home/home_shell_page.dart';
import 'package:room_temperature_app/splash/splash_page.dart';

part 'router.g.dart';

/// Branded intro shown on a cold start, then replaced by [HomeRoute].
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  /// Creates a [SplashRoute].
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SplashPage(
      onFinished: () {
        if (context.mounted) {
          const HomeRoute().go(context);
        }
      },
    );
  }
}

/// The local-only home route: a bottom-nav shell over the dashboard,
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
