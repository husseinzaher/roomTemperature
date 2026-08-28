import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_database/local_database.dart';
import 'package:room_temperature_app/places/place_history_repository.dart';

void main() {
  group('PlaceHistoryRepository', () {
    late AppDatabase database;
    late PlaceHistoryRepository repository;
    final t0 = DateTime.utc(2026, 8, 28, 8);

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = PlaceHistoryRepository(database: database);
    });

    tearDown(() => database.close());

    test('does not collect when history is disabled', () async {
      await repository.observe(
        enabled: false,
        latitude: 30,
        longitude: 31,
        at: t0,
        indoorCelsius: 24,
      );
      expect(await repository.listPlaces(), isEmpty);
    });

    test('groups repeated visits to the same place', () async {
      await _completeVisit(
        repository,
        lat: 30,
        lng: 31,
        start: t0,
        indoor: 24,
      );
      await _completeVisit(
        repository,
        lat: 30.0004,
        lng: 31.0004,
        start: t0.add(const Duration(hours: 5)),
        indoor: 24.6,
      );

      final places = await repository.listPlaces();
      expect(places, hasLength(1));
      expect(places.single.visitCount, 2);
      expect(places.single.averageIndoorCelsius, closeTo(24.3, 0.01));
    });

    test('computes place statistics from indoor samples', () async {
      await _completeVisit(
        repository,
        lat: 30,
        lng: 31,
        start: t0,
        indoor: 23,
        indoor2: 25,
      );

      final place = (await repository.listPlaces()).single;
      expect(place.minIndoorCelsius, 23);
      expect(place.maxIndoorCelsius, 25);
      expect(place.averageIndoorCelsius, 24);
      expect(place.totalDuration, const Duration(minutes: 30));
    });

    test('deleteAll removes history and deletePlace removes one cluster',
        () async {
      await _completeVisit(
        repository,
        lat: 30,
        lng: 31,
        start: t0,
        indoor: 24,
      );
      await _completeVisit(
        repository,
        lat: 31,
        lng: 32,
        start: t0.add(const Duration(hours: 2)),
        indoor: 22,
      );

      var places = await repository.listPlaces();
      expect(places, hasLength(2));
      await repository.deletePlace(places.first.id);
      places = await repository.listPlaces();
      expect(places, hasLength(1));
      await repository.deleteAll();
      expect(await repository.listPlaces(), isEmpty);
    });
  });
}

Future<void> _completeVisit(
  PlaceHistoryRepository repository, {
  required double lat,
  required double lng,
  required DateTime start,
  required double indoor,
  double? indoor2,
}) async {
  await repository.observe(
    enabled: true,
    latitude: lat,
    longitude: lng,
    at: start,
    indoorCelsius: indoor,
  );
  await repository.observe(
    enabled: true,
    latitude: lat,
    longitude: lng,
    at: start.add(const Duration(minutes: 30)),
    indoorCelsius: indoor2 ?? indoor,
  );
  await repository.stopTracking();
}
