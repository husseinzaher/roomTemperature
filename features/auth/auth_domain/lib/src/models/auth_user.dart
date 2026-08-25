import 'package:equatable/equatable.dart';

/// {@template auth_user}
/// A minimal, Firebase-agnostic representation of an authenticated user.
///
/// Deliberately kept small — profile data such as measurement units or
/// temperature thresholds belongs to the settings feature, not auth.
/// {@endtemplate}
class AuthUser extends Equatable {
  /// {@macro auth_user}
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
  });

  /// The stable, unique identifier for this user.
  final String uid;

  /// The user's email address, if any.
  final String? email;

  /// The user's display name, if any.
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}
