import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/cubit/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sign_up_cubit}
/// Drives the sign-up form, delegating account creation to a
/// [SignUpCommand].
///
/// Validates that the password and its confirmation match before calling
/// the repository.
/// {@endtemplate}
class SignUpCubit extends Cubit<SignUpState> {
  /// {@macro sign_up_cubit}
  SignUpCubit(this._signUpCommand) : super(const SignUpState());

  final SignUpCommand _signUpCommand;

  /// Attempts to create an account with [email] and [password], after
  /// verifying [password] matches [confirmPassword].
  Future<void> submit({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      emit(
        const SignUpState(
          status: SignUpStatus.failure,
          errorCode: 'password-mismatch',
        ),
      );
      return;
    }

    emit(const SignUpState(status: SignUpStatus.submitting));
    try {
      await _signUpCommand.execute(email: email, password: password);
      emit(const SignUpState(status: SignUpStatus.success));
    } on AuthException catch (exception) {
      emit(
        SignUpState(status: SignUpStatus.failure, errorCode: exception.code),
      );
    } on Object catch (_) {
      emit(
        const SignUpState(status: SignUpStatus.failure, errorCode: 'unknown'),
      );
    }
  }
}
