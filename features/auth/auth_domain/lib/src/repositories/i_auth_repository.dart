import 'package:auth_domain/src/models/auth_user.dart';

/// {@template i_auth_repository}
/// Contract for authentication operations, implemented by the data layer
/// (e.g. a Firebase-backed repository) and consumed by the domain's
/// commands and queries.
/// {@endtemplate}
abstract interface class IAuthRepository {
  /// Emits the currently authenticated [AuthUser], or `null` when signed
  /// out, every time the auth state changes.
  Stream<AuthUser?> watchAuthState();

  /// Signs in an existing user with [email] and [password].
  ///
  /// Throws an `AuthException` on failure.
  Future<AuthUser> signIn({required String email, required String password});

  /// Creates a new account with [email] and [password].
  ///
  /// Throws an `AuthException` on failure.
  Future<AuthUser> signUp({required String email, required String password});

  /// Sends a password reset email to [email].
  ///
  /// Throws an `AuthException` on failure.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs the current user out.
  Future<void> signOut();
}
