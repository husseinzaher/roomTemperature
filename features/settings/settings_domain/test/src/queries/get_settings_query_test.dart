import 'package:mocktail/mocktail.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  group('GetSettingsQuery', () {
    late ISettingsRepository repository;
    late GetSettingsQuery query;

    setUp(() {
      repository = MockSettingsRepository();
      query = GetSettingsQuery(repository);
    });

    test('watch delegates to repository.watchSettings', () {
      final settings = UserSettings.defaults();
      when(
        () => repository.watchSettings(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(settings));

      expect(query.watch(userId: 'user-1'), emits(settings));
      verify(() => repository.watchSettings(userId: 'user-1')).called(1);
    });
  });
}
