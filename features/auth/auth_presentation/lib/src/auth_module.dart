import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/cubit/auth_status_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// {@template auth_module}
/// The single place that constructs auth's commands and queries from an
/// injected [IAuthRepository] and exposes them via [Provider], so that
/// pages can e.g. `context.read<SignInCommand>()` to build their cubits.
///
/// Also provides an [AuthStatusCubit] for app-level auth-state observation
/// (e.g. router redirects).
/// {@endtemplate}
class AuthModule extends StatelessWidget {
  /// {@macro auth_module}
  const AuthModule({
    required this.authRepository,
    required this.child,
    super.key,
  });

  /// The concrete auth repository backing this module (typically a
  /// `FirebaseAuthRepository` from `auth_data`).
  final IAuthRepository authRepository;

  /// The widget subtree that can access auth's commands, queries, and
  /// [AuthStatusCubit].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IAuthRepository>.value(value: authRepository),
        Provider(create: (ctx) => SignInCommand(ctx.read<IAuthRepository>())),
        Provider(create: (ctx) => SignUpCommand(ctx.read<IAuthRepository>())),
        Provider(
          create: (ctx) => SignOutCommand(ctx.read<IAuthRepository>()),
        ),
        Provider(
          create: (ctx) => SendPasswordResetCommand(
            ctx.read<IAuthRepository>(),
          ),
        ),
        Provider(
          create: (ctx) => WatchAuthStateQuery(ctx.read<IAuthRepository>()),
        ),
        BlocProvider(
          create: (ctx) => AuthStatusCubit(ctx.read<WatchAuthStateQuery>()),
        ),
      ],
      child: child,
    );
  }
}
