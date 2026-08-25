import 'package:auth_data/src/converters/firebase_auth_exception_converter.dart';
import 'package:auth_data/src/converters/firebase_user_to_auth_user_converter.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// {@template firebase_auth_repository}
/// A [IAuthRepository] implementation backed by `firebase_auth`.
/// {@endtemplate}
class FirebaseAuthRepository implements IAuthRepository {
  /// {@macro firebase_auth_repository}
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseUserToAuthUserConverter userConverter =
        const FirebaseUserToAuthUserConverter(),
    FirebaseAuthExceptionConverter exceptionConverter =
        const FirebaseAuthExceptionConverter(),
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       // An initializing formal (`this._userConverter`) would make the
       // parameter private and thus unusable by callers in other files
       // (e.g. tests), so it's assigned explicitly here instead.
       // ignore: prefer_initializing_formals
       _userConverter = userConverter,
       // Same reasoning as above.
       // ignore: prefer_initializing_formals
       _exceptionConverter = exceptionConverter;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseUserToAuthUserConverter _userConverter;
  final FirebaseAuthExceptionConverter _exceptionConverter;

  @override
  Stream<AuthUser?> watchAuthState() => _firebaseAuth.authStateChanges().map(
    (user) => user == null ? null : _userConverter.convert(user),
  );

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (exception) {
      throw _exceptionConverter.convert(exception);
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (exception) {
      throw _exceptionConverter.convert(exception);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (exception) {
      throw _exceptionConverter.convert(exception);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (exception) {
      throw _exceptionConverter.convert(exception);
    }
  }

  AuthUser _userFromCredential(firebase_auth.UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw const AuthException(
        code: 'unknown',
        message: 'Firebase returned no user.',
      );
    }
    return _userConverter.convert(user);
  }
}
