import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchAuthStateQuery extends Mock implements WatchAuthStateQuery {}

void main() {
  group('AuthStatusCubit', () {
    test('initial state is null', () {
      final query = MockWatchAuthStateQuery();
      // mocktail needs the call wrapped in a closure to record it; a
      // tearoff of `query.watch` would not be intercepted.
      // ignore: unnecessary_lambdas
      when(() => query.watch()).thenAnswer((_) => const Stream.empty());

      final cubit = AuthStatusCubit(query);
      addTearDown(cubit.close);

      expect(cubit.state, isNull);
    });

    test('emits the users produced by watch()', () async {
      const user = AuthUser(uid: 'uid');
      final query = MockWatchAuthStateQuery();
      // mocktail needs the call wrapped in a closure to record it; a
      // tearoff of `query.watch` would not be intercepted.
      // ignore: unnecessary_lambdas
      when(() => query.watch()).thenAnswer((_) => Stream.value(user));

      final cubit = AuthStatusCubit(query);
      addTearDown(cubit.close);

      await expectLater(cubit.stream, emits(user));
      expect(cubit.state, user);
    });
  });
}
