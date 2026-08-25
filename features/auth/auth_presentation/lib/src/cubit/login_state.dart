import 'package:equatable/equatable.dart';

/// The status of a [LoginState].
enum LoginStatus {
  /// The form has not been submitted yet.
  initial,

  /// The sign-in request is in flight.
  submitting,

  /// The sign-in request succeeded.
  success,

  /// The sign-in request failed.
  failure,
}

/// {@template login_state}
/// State for `LoginCubit`.
/// {@endtemplate}
class LoginState extends Equatable {
  /// {@macro login_state}
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorCode,
  });

  /// The current status of the login attempt.
  final LoginStatus status;

  /// A machine-readable error code (e.g. from `AuthException.code`), set
  /// when [status] is [LoginStatus.failure].
  final String? errorCode;

  /// Returns a copy of this state with the given fields replaced.
  LoginState copyWith({
    LoginStatus? status,
    String? errorCode,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [status, errorCode];
}
