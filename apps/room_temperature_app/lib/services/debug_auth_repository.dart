import 'dart:async';

import 'package:auth_domain/auth_domain.dart';

/// The fake user signed in via [DebugAuthRepository.debugSignInAsGuest].
const debugGuestUser = AuthUser(
  uid: 'debug-guest',
  email: 'debug@local.test',
  displayName: 'Debug Guest',
);

/// {@template debug_auth_repository}
/// Wraps a real [IAuthRepository] with a debug-only bypass that signs the
/// user in locally, without ever calling Firebase — for testing the app
/// before Email/Password sign-in is enabled in the Firebase console, or for
/// quick manual testing in general.
///
/// Only ever constructed when `kDebugMode` is true (see `app/view/app.dart`)
/// — it must never ship in a release build.
/// {@endtemplate}
class DebugAuthRepository implements IAuthRepository {
  /// {@macro debug_auth_repository}
  DebugAuthRepository(this._real) {
    _subscription = _real.watchAuthState().listen((user) {
      _lastRealUser = user;
      _controller.add(_debugUser ?? user);
    });
  }

  final IAuthRepository _real;
  final _controller = StreamController<AuthUser?>.broadcast();
  StreamSubscription<AuthUser?>? _subscription;
  AuthUser? _debugUser;
  AuthUser? _lastRealUser;

  /// Signs in as a fake local user, bypassing Firebase entirely.
  void debugSignInAsGuest() {
    _debugUser = debugGuestUser;
    _controller.add(_debugUser);
  }

  @override
  Stream<AuthUser?> watchAuthState() => _controller.stream;

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return _real.signIn(email: email, password: password);
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    return _real.signUp(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _real.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    _debugUser = null;
    await _real.signOut();
    _controller.add(_lastRealUser);
  }

  /// Releases the underlying subscription. Not part of [IAuthRepository] —
  /// call directly when tearing this down.
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
