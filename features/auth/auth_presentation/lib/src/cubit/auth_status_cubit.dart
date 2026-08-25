import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template auth_status_cubit}
/// Exposes the current [AuthUser] (or `null` when signed out) as a
/// [Cubit], subscribing to a [WatchAuthStateQuery].
///
/// Useful for the app-level router's redirect logic.
/// {@endtemplate}
class AuthStatusCubit extends Cubit<AuthUser?> {
  /// {@macro auth_status_cubit}
  AuthStatusCubit(WatchAuthStateQuery watchAuthStateQuery) : super(null) {
    _subscription = watchAuthStateQuery.watch().listen(emit);
  }

  late final StreamSubscription<AuthUser?> _subscription;

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
