import 'package:auth_domain/src/models/auth_user.dart';
import 'package:auth_domain/src/repositories/i_auth_repository.dart';

/// {@template sign_up_command}
/// Creates a new account via the injected [IAuthRepository].
/// {@endtemplate}
class SignUpCommand {
  /// {@macro sign_up_command}
  const SignUpCommand(this._repository);

  final IAuthRepository _repository;

  /// Creates a new account with [email] and [password].
  Future<AuthUser> execute({
    required String email,
    required String password,
  }) => _repository.signUp(email: email, password: password);
}
