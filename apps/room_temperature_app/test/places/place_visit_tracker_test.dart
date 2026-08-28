import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_database/local_database.dart';
import 'package:room_temperature_app/places/place_history_repository.dart';
import 'package:room_temperature_app/places/place_visit_tracker.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

class _FakeLocationService extends LocationService {
  const _FakeLocationService({
    this.permission = LocationPermission.whileInUse,
    this.serviceEnabled = true,
    this.location,
  });

  final LocationPermission permission;
  final bool serviceEnabled;
  final Location? location;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<Location?> lastKnownOrNull() async => location;
}

void main() {
  group('PlaceVisitTracker', () {
    late AppDatabase database;
    late PlaceHistoryRepository repository;
    final at = DateTime.utc(2026, 8, 28, 12);
    const home = Location(latitude: 30, longitude: 31);

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = PlaceHistoryRepository(database: database);
    });

    tearDown(() => database.close());

    test('does not collect when permission is denied', () async {
      final tracker = PlaceVisitTracker(
        repository: repository,
        locationService: const _FakeLocationService(
          permission: LocationPermission.denied,
          location: home,
        ),
      );

      await tracker.observe(
        settings: UserSettings.defaults(),
        indoorCelsius: 24,
        at: at,
      );

      expect(await database.readOpenVisit(), isNull);
    });

    test('does not collect when permission is denied forever', () async {
      final tracker = PlaceVisitTracker(
        repository: repository,
        locationService: const _FakeLocationService(
          permission: LocationPermission.deniedForever,
          location: home,
        ),
      );

      await tracker.observe(
        settings: UserSettings.defaults(),
        indoorCelsius: 24,
        at: at,
      );

      expect(await database.readOpenVisit(), isNull);
    });

    test('does not collect when location services are disabled', () async {
      final tracker = PlaceVisitTracker(
        repository: repository,
        locationService: const _FakeLocationService(
          serviceEnabled: false,
          location: home,
        ),
      );

      await tracker.observe(
        settings: UserSettings.defaults(),
        indoorCelsius: 24,
        at: at,
      );

      expect(await database.readOpenVisit(), isNull);
    });

    test('opens a visit when permission is granted', () async {
      final tracker = PlaceVisitTracker(
        repository: repository,
        locationService: const _FakeLocationService(location: home),
      );

      await tracker.observe(
        settings: UserSettings.defaults(),
        indoorCelsius: 24,
        at: at,
      );

      final open = await database.readOpenVisit();
      expect(open, isNotNull);
      expect(open!.latitude, 30);
      expect(open.longitude, 31);
    });

    test('does not collect when place history is disabled', () async {
      final tracker = PlaceVisitTracker(
        repository: repository,
        locationService: const _FakeLocationService(location: home),
      );

      await tracker.observe(
        settings: UserSettings.defaults().copyWith(
          placeHistoryEnabled: false,
        ),
        indoorCelsius: 24,
        at: at,
      );

      expect(await database.readOpenVisit(), isNull);
    });
  });
}
