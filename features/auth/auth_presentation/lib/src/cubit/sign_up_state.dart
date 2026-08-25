import 'package:equatable/equatable.dart';

/// The status of a [SignUpState].
enum SignUpStatus {
  /// The form has not been submitted yet.
  initial,

  /// The sign-up request is in flight.
  submitting,

  /// The sign-up request succeeded.
  success,

  /// The sign-up request, or local validation, failed.
  failure,
}

/// {@template sign_up_state}
/// State for `SignUpCubit`.
/// {@endtemplate}
class SignUpState extends Equatable {
  /// {@macro sign_up_state}
  const SignUpState({
    this.status = SignUpStatus.initial,
    this.errorCode,
  });

  /// The current status of the sign-up attempt.
  final SignUpStatus status;

  /// A machine-readable error code, set when [status] is
  /// [SignUpStatus.failure]. In addition to `AuthException.code` values,
  /// this may be `'password-mismatch'` for a local validation failure.
  final String? errorCode;

  /// Returns a copy of this state with the given fields replaced.
  SignUpState copyWith({
    SignUpStatus? status,
    String? errorCode,
  }) {
    return SignUpState(
      status: status ?? this.status,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [status, errorCode];
}
