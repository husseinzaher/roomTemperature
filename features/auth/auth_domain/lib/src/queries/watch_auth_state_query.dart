import 'package:auth_domain/src/models/auth_user.dart';
import 'package:auth_domain/src/repositories/i_auth_repository.dart';

/// {@template watch_auth_state_query}
/// Watches the current auth state via the injected [IAuthRepository].
/// {@endtemplate}
class WatchAuthStateQuery {
  /// {@macro watch_auth_state_query}
  const WatchAuthStateQuery(this._repository);

  final IAuthRepository _repository;

  /// Emits the currently authenticated [AuthUser], or `null` when signed
  /// out, every time the auth state changes.
  Stream<AuthUser?> watch() => _repository.watchAuthState();
}
