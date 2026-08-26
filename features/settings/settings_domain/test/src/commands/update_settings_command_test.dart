import 'package:mocktail/mocktail.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  group('UpdateSettingsCommand', () {
    late ISettingsRepository repository;
    late UpdateSettingsCommand command;

    setUp(() {
      repository = MockSettingsRepository();
      command = UpdateSettingsCommand(repository);
    });

    test('execute delegates to repository.updateSettings', () async {
      final settings = UserSettings.defaults();
      when(
        () => repository.updateSettings(settings: settings),
      ).thenAnswer((_) async {});

      await command.execute(settings: settings);

      verify(() => repository.updateSettings(settings: settings)).called(1);
    });

    test('execute propagates repository errors', () {
      final settings = UserSettings.defaults();
      when(
        () => repository.updateSettings(settings: settings),
      ).thenThrow(Exception('boom'));

      expect(() => command.execute(settings: settings), throwsException);
    });
  });
}
