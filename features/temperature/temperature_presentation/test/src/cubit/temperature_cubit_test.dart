import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';

class MockTemperatureRepository extends Mock
    implements ITemperatureRepository {}

class MockWeatherRepository extends Mock implements IWeatherRepository {}

void main() {
  group('TemperatureCubit', () {
    late ITemperatureRepository temperatureRepository;
    late IWeatherRepository weatherRepository;
    const estimator = RoomTemperatureEstimator();
    const location = Location(latitude: 25, longitude: 55);

    final cachedReading = Reading(
      roomTemperatureCelsius: 22,
      roomTemperatureSource: RoomTemperatureSource.estimated,
      outsideTemperatureCelsius: 19,
      timestamp: DateTime.utc(2026),
    );

    setUpAll(() {
      registerFallbackValue(cachedReading);
    });

    setUp(() {
      temperatureRepository = MockTemperatureRepository();
      weatherRepository = MockWeatherRepository();
    });

    TemperatureCubit buildCubit({
      Stream<Reading?>? watchStream,
      Future<double?> Function()? readAmbientSensor,
      double indoorOffset = 2,
    }) {
      when(
        () => temperatureRepository.watchLatestReading(userId: 'user-1'),
      ).thenAnswer((_) => watchStream ?? const Stream.empty());
      when(
        () => temperatureRepository.recordReading(
          userId: any(named: 'userId'),
          reading: any(named: 'reading'),
        ),
      ).thenAnswer((_) async {});

      return TemperatureCubit(
        userId: 'user-1',
        temperatureRepository: temperatureRepository,
        weatherRepository: weatherRepository,
        estimator: estimator,
        getLocation: () async => location,
        getIndoorOffset: () => indoorOffset,
        readAmbientSensor: readAmbientSensor,
      );
    }

    test('initial state is loading with no reading', () async {
      final cubit = buildCubit();
      expect(cubit.state, const TemperatureState.loading());
      await cubit.close();
    });

    blocTest<TemperatureCubit, TemperatureState>(
      'emits a loaded state when watchLatestReading emits a cached reading',
      build: () => buildCubit(watchStream: Stream.value(cachedReading)),
      expect: () => [TemperatureState.loaded(reading: cachedReading)],
    );

    blocTest<TemperatureCubit, TemperatureState>(
      'refresh() uses the real sensor reading when available',
      build: () => buildCubit(readAmbientSensor: () async => 25.5),
      setUp: () {
        when(
          () => weatherRepository.fetchOutsideTemperatureCelsius(
            location: location,
          ),
        ).thenAnswer((_) async => 30);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<TemperatureState>().having(
          (s) => s.status,
          'status',
          TemperatureStatus.loading,
        ),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.loaded)
            .having(
              (s) => s.reading?.roomTemperatureSource,
              'roomTemperatureSource',
              RoomTemperatureSource.sensor,
            )
            .having(
              (s) => s.reading?.roomTemperatureCelsius,
              'roomTemperatureCelsius',
              25.5,
            )
            .having(
              (s) => s.reading?.outsideTemperatureCelsius,
              'outsideTemperatureCelsius',
              30,
            ),
      ],
      verify: (_) {
        verify(
          () => temperatureRepository.recordReading(
            userId: 'user-1',
            reading: any(
              named: 'reading',
              that: isA<Reading>().having(
                (r) => r.roomTemperatureSource,
                'roomTemperatureSource',
                RoomTemperatureSource.sensor,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<TemperatureCubit, TemperatureState>(
      'refresh() falls back to the estimator when no sensor is available',
      build: buildCubit,
      setUp: () {
        when(
          () => weatherRepository.fetchOutsideTemperatureCelsius(
            location: location,
          ),
        ).thenAnswer((_) async => 20);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<TemperatureState>().having(
          (s) => s.status,
          'status',
          TemperatureStatus.loading,
        ),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.loaded)
            .having(
              (s) => s.reading?.roomTemperatureSource,
              'roomTemperatureSource',
              RoomTemperatureSource.estimated,
            )
            .having(
              (s) => s.reading?.roomTemperatureCelsius,
              'roomTemperatureCelsius',
              22,
            ),
      ],
    );

    blocTest<TemperatureCubit, TemperatureState>(
      'refresh() falls back to the estimator when sensor resolves null',
      build: () => buildCubit(readAmbientSensor: () async => null),
      setUp: () {
        when(
          () => weatherRepository.fetchOutsideTemperatureCelsius(
            location: location,
          ),
        ).thenAnswer((_) async => 18);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<TemperatureState>().having(
          (s) => s.status,
          'status',
          TemperatureStatus.loading,
        ),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.loaded)
            .having(
              (s) => s.reading?.roomTemperatureSource,
              'roomTemperatureSource',
              RoomTemperatureSource.estimated,
            )
            .having(
              (s) => s.reading?.roomTemperatureCelsius,
              'roomTemperatureCelsius',
              20,
            ),
      ],
    );

    blocTest<TemperatureCubit, TemperatureState>(
      'refresh() emits an error state when the weather fetch fails',
      build: buildCubit,
      setUp: () {
        when(
          () => weatherRepository.fetchOutsideTemperatureCelsius(
            location: location,
          ),
        ).thenThrow(Exception('network down'));
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<TemperatureState>().having(
          (s) => s.status,
          'status',
          TemperatureStatus.loading,
        ),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<TemperatureCubit, TemperatureState>(
      'refresh() error preserves a previously loaded reading',
      build: () => buildCubit(watchStream: Stream.value(cachedReading)),
      setUp: () {
        when(
          () => weatherRepository.fetchOutsideTemperatureCelsius(
            location: location,
          ),
        ).thenThrow(Exception('network down'));
      },
      act: (cubit) async {
        // Let the cached reading from watchLatestReading land first.
        await Future<void>.delayed(Duration.zero);
        await cubit.refresh();
      },
      expect: () => [
        TemperatureState.loaded(reading: cachedReading),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.loading)
            .having((s) => s.reading, 'reading', cachedReading),
        isA<TemperatureState>()
            .having((s) => s.status, 'status', TemperatureStatus.error)
            .having((s) => s.reading, 'reading', cachedReading),
      ],
    );
  });
}
