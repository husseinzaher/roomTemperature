import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template login_cubit}
/// Drives the login form, delegating the sign-in attempt to a
/// [SignInCommand].
/// {@endtemplate}
class LoginCubit extends Cubit<LoginState> {
  /// {@macro login_cubit}
  LoginCubit(this._signInCommand) : super(const LoginState());

  final SignInCommand _signInCommand;

  /// Attempts to sign in with [email] and [password].
  Future<void> submit({
    required String email,
    required String password,
  }) async {
    emit(const LoginState(status: LoginStatus.submitting));
    try {
      await _signInCommand.execute(email: email, password: password);
      emit(const LoginState(status: LoginStatus.success));
    } on AuthException catch (exception) {
      emit(
        LoginState(status: LoginStatus.failure, errorCode: exception.code),
      );
    } on Object catch (_) {
      emit(
        const LoginState(status: LoginStatus.failure, errorCode: 'unknown'),
      );
    }
  }
}
