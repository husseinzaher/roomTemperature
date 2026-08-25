import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUser extends Mock implements firebase_auth.User {}

class MockFirebaseAuthException extends Mock
    implements firebase_auth.FirebaseAuthException {}

void main() {
  group('FirebaseAuthRepository', () {
    late firebase_auth.FirebaseAuth firebaseAuth;
    late FirebaseAuthRepository repository;
    late MockUser user;
    late MockUserCredential credential;

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      repository = FirebaseAuthRepository(firebaseAuth: firebaseAuth);
      user = MockUser();
      credential = MockUserCredential();
      when(() => user.uid).thenReturn('uid');
      when(() => user.email).thenReturn('a@b.com');
      when(() => user.displayName).thenReturn('A');
      when(() => credential.user).thenReturn(user);
    });

    group('watchAuthState', () {
      test('maps emitted users through the converter', () {
        when(
          () => firebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(user));

        expect(
          repository.watchAuthState(),
          emits(
            const AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A'),
          ),
        );
      });

      test('emits null when signed out', () {
        when(
          () => firebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(null));

        expect(repository.watchAuthState(), emits(null));
      });
    });

    group('signIn', () {
      test('returns the converted user on success', () async {
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => credential);

        final result = await repository.signIn(
          email: 'a@b.com',
          password: 'password',
        );

        expect(
          result,
          const AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A'),
        );
      });

      test('rethrows FirebaseAuthException as AuthException', () async {
        final exception = MockFirebaseAuthException();
        when(() => exception.code).thenReturn('wrong-password');
        when(() => exception.message).thenReturn('nope');
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: 'a@b.com',
            password: 'wrong',
          ),
        ).thenThrow(exception);

        expect(
          () => repository.signIn(email: 'a@b.com', password: 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signUp', () {
      test('returns the converted user on success', () async {
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => credential);

        final result = await repository.signUp(
          email: 'a@b.com',
          password: 'password',
        );

        expect(
          result,
          const AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A'),
        );
      });

      test('rethrows FirebaseAuthException as AuthException', () async {
        final exception = MockFirebaseAuthException();
        when(() => exception.code).thenReturn('email-already-in-use');
        when(() => exception.message).thenReturn('taken');
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenThrow(exception);

        expect(
          () => repository.signUp(email: 'a@b.com', password: 'password'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('delegates to firebaseAuth', () async {
        when(
          () => firebaseAuth.sendPasswordResetEmail(email: 'a@b.com'),
        ).thenAnswer((_) async {});

        await repository.sendPasswordResetEmail(email: 'a@b.com');

        verify(
          () => firebaseAuth.sendPasswordResetEmail(email: 'a@b.com'),
        ).called(1);
      });

      test('rethrows FirebaseAuthException as AuthException', () async {
        final exception = MockFirebaseAuthException();
        when(() => exception.code).thenReturn('network-request-failed');
        when(() => exception.message).thenReturn('no network');
        when(
          () => firebaseAuth.sendPasswordResetEmail(email: 'a@b.com'),
        ).thenThrow(exception);

        expect(
          () => repository.sendPasswordResetEmail(email: 'a@b.com'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signOut', () {
      test('delegates to firebaseAuth', () async {
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

        await repository.signOut();

        verify(() => firebaseAuth.signOut()).called(1);
      });
    });
  });
}
