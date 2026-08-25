import 'package:auth_domain/auth_domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// {@template firebase_auth_exception_converter}
/// Converts a [firebase_auth.FirebaseAuthException] into a domain
/// [AuthException], keyed off the Firebase exception's `.code`.
///
/// This is the single place responsible for translating Firebase's error
/// vocabulary into the domain/presentation-facing one, so no Firebase
/// exception type ever leaks upward.
/// {@endtemplate}
class FirebaseAuthExceptionConverter {
  /// {@macro firebase_auth_exception_converter}
  const FirebaseAuthExceptionConverter();

  /// Converts [exception] into an [AuthException].
  AuthException convert(firebase_auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return AuthException(
          code: 'invalid-credentials',
          message: exception.message ?? 'The email or password is incorrect.',
        );
      case 'email-already-in-use':
        return AuthException(
          code: 'email-in-use',
          message: exception.message ?? 'This email is already in use.',
        );
      case 'weak-password':
        return AuthException(
          code: 'weak-password',
          message: exception.message ?? 'The password is too weak.',
        );
      case 'network-request-failed':
        return AuthException(
          code: 'network-error',
          message: exception.message ?? 'A network error occurred.',
        );
      default:
        return AuthException(
          code: 'unknown',
          message: exception.message ?? 'An unknown error occurred.',
        );
    }
  }
}
