import 'package:equatable/equatable.dart';

/// The status of a [ForgotPasswordState].
enum ForgotPasswordStatus {
  /// The form has not been submitted yet.
  initial,

  /// The reset request is in flight.
  submitting,

  /// The reset email was sent successfully.
  sent,

  /// The reset request failed.
  failure,
}

/// {@template forgot_password_state}
/// State for `ForgotPasswordCubit`.
/// {@endtemplate}
class ForgotPasswordState extends Equatable {
  /// {@macro forgot_password_state}
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.errorCode,
  });

  /// The current status of the reset attempt.
  final ForgotPasswordStatus status;

  /// A machine-readable error code (e.g. from `AuthException.code`), set
  /// when [status] is [ForgotPasswordStatus.failure].
  final String? errorCode;

  /// Returns a copy of this state with the given fields replaced.
  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? errorCode,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [status, errorCode];
}
