import 'package:auth_domain/src/repositories/i_auth_repository.dart';

/// {@template sign_out_command}
/// Signs the current user out via the injected [IAuthRepository].
/// {@endtemplate}
class SignOutCommand {
  /// {@macro sign_out_command}
  const SignOutCommand(this._repository);

  final IAuthRepository _repository;

  /// Signs the current user out.
  Future<void> execute() => _repository.signOut();
}
