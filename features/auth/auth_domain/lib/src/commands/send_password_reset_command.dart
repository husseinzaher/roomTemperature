import 'package:auth_domain/src/repositories/i_auth_repository.dart';

/// {@template send_password_reset_command}
/// Sends a password reset email via the injected [IAuthRepository].
/// {@endtemplate}
class SendPasswordResetCommand {
  /// {@macro send_password_reset_command}
  const SendPasswordResetCommand(this._repository);

  final IAuthRepository _repository;

  /// Sends a password reset email to [email].
  Future<void> execute({required String email}) =>
      _repository.sendPasswordResetEmail(email: email);
}
