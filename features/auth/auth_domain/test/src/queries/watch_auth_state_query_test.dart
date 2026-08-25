import 'package:auth_domain/auth_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('WatchAuthStateQuery', () {
    late IAuthRepository repository;
    late WatchAuthStateQuery query;

    setUp(() {
      repository = MockAuthRepository();
      query = WatchAuthStateQuery(repository);
    });

    test('delegates to repository.watchAuthState', () {
      const user = AuthUser(uid: 'uid');
      when(
        () => repository.watchAuthState(),
      ).thenAnswer((_) => Stream.value(user));

      expect(query.watch(), emits(user));
      verify(() => repository.watchAuthState()).called(1);
    });

    test('emits null when signed out', () {
      when(
        () => repository.watchAuthState(),
      ).thenAnswer((_) => Stream.value(null));

      expect(query.watch(), emits(null));
    });
  });
}
