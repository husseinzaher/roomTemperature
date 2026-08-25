import 'package:auth_domain/auth_domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// {@template firebase_user_to_auth_user_converter}
/// Converts a Firebase [firebase_auth.User] into a domain [AuthUser].
///
/// A Firebase `User` must never escape the data layer, so this converter is
/// the single place responsible for that translation.
/// {@endtemplate}
class FirebaseUserToAuthUserConverter {
  /// {@macro firebase_user_to_auth_user_converter}
  const FirebaseUserToAuthUserConverter();

  /// Converts [user] into an [AuthUser].
  AuthUser convert(firebase_auth.User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
  );
}
