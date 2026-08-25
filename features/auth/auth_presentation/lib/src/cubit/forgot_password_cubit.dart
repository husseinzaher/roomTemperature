import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/cubit/forgot_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template forgot_password_cubit}
/// Drives the forgot-password form, delegating to a
/// [SendPasswordResetCommand].
/// {@endtemplate}
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  /// {@macro forgot_password_cubit}
  ForgotPasswordCubit(this._sendPasswordResetCommand)
    : super(const ForgotPasswordState());

  final SendPasswordResetCommand _sendPasswordResetCommand;

  /// Sends a password reset email to [email].
  Future<void> submit({required String email}) async {
    emit(const ForgotPasswordState(status: ForgotPasswordStatus.submitting));
    try {
      await _sendPasswordResetCommand.execute(email: email);
      emit(const ForgotPasswordState(status: ForgotPasswordStatus.sent));
    } on AuthException catch (exception) {
      emit(
        ForgotPasswordState(
          status: ForgotPasswordStatus.failure,
          errorCode: exception.code,
        ),
      );
    } on Object catch (_) {
      emit(
        const ForgotPasswordState(
          status: ForgotPasswordStatus.failure,
          errorCode: 'unknown',
        ),
      );
    }
  }
}
