/// {@template auth_exception}
/// A domain-level exception raised by `IAuthRepository` implementations.
///
/// Data-layer implementations (e.g. Firebase-backed ones) must catch their
/// own SDK exceptions and rethrow them as an [AuthException] so that no
/// third-party exception type ever leaks into the domain or presentation
/// layers.
/// {@endtemplate}
class AuthException implements Exception {
  /// {@macro auth_exception}
  const AuthException({
    required this.code,
    required this.message,
  });

  /// A stable, machine-readable identifier for the failure, e.g.
  /// `'invalid-credentials'`, `'weak-password'`, `'email-in-use'`,
  /// `'network-error'`, or `'unknown'`.
  final String code;

  /// A human-readable description of the failure, primarily useful for
  /// logging (presentation should prefer mapping [code] to a localized
  /// message).
  final String message;

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}
