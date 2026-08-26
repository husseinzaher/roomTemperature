import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:room_temperature_app/home/home_shell_page.dart';

part 'router.g.dart';

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
