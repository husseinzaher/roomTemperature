import 'package:auth_domain/src/models/auth_user.dart';
import 'package:auth_domain/src/repositories/i_auth_repository.dart';

/// {@template sign_in_command}
/// Signs an existing user in via the injected [IAuthRepository].
/// {@endtemplate}
class SignInCommand {
  /// {@macro sign_in_command}
  const SignInCommand(this._repository);

  final IAuthRepository _repository;

  /// Signs in the user identified by [email] and [password].
  Future<AuthUser> execute({
    required String email,
    required String password,
  }) => _repository.signIn(email: email, password: password);
}
