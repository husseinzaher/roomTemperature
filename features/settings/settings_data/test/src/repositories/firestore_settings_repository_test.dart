import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('FirestoreSettingsRepository', () {
    late FakeFirebaseFirestore firestore;

    const userId = 'user-1';
    const converter = UserSettingsConverter();
    final settings = UserSettings.defaults().copyWith(
      indoorOffsetCelsius: 1.5,
    );

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('watchSettings', () {
      test(
        'emits only the live snapshot when there is no local cache',
        () async {
          await firestore
              .collection('users')
              .doc(userId)
              .set(converter.toMap(settings));

          final repository = FirestoreSettingsRepository(firestore: firestore);

          expect(repository.watchSettings(userId: userId), emits(settings));
        },
      );

      test('emits the cached value first, then the live snapshot', () async {
        final cachedSettings = UserSettings.defaults().copyWith(
          indoorOffsetCelsius: -3,
        );
        SharedPreferences.setMockInitialValues({
          'settings_cache_$userId': jsonEncode(
            converter.toMap(cachedSettings),
          ),
        });
        final cache = await SharedPreferences.getInstance();

        await firestore
            .collection('users')
            .doc(userId)
            .set(converter.toMap(settings));

        final repository = FirestoreSettingsRepository(
          firestore: firestore,
          localCache: cache,
        );

        await expectLater(
          repository.watchSettings(userId: userId),
          emitsInOrder([cachedSettings, settings]),
        );
      });

      test('writes each live snapshot back to the local cache', () async {
        SharedPreferences.setMockInitialValues({});
        final cache = await SharedPreferences.getInstance();

        await firestore
            .collection('users')
            .doc(userId)
            .set(converter.toMap(settings));

        final repository = FirestoreSettingsRepository(
          firestore: firestore,
          localCache: cache,
        );

        await repository.watchSettings(userId: userId).first;

        expect(
          cache.getString('settings_cache_$userId'),
          jsonEncode(converter.toMap(settings)),
        );
      });

      test('treats a missing document as defaults', () {
        final repository = FirestoreSettingsRepository(firestore: firestore);

        expect(
          repository.watchSettings(userId: userId),
          emits(UserSettings.defaults()),
        );
      });
    });

    group('updateSettings', () {
      test(
        'merge-writes only the owned fields to the profile document',
        () async {
          final repository = FirestoreSettingsRepository(firestore: firestore);
          await repository.updateSettings(userId: userId, settings: settings);

          final snapshot = await firestore
              .collection('users')
              .doc(userId)
              .get();

          expect(snapshot.data(), converter.toMap(settings));
        },
      );

      test(
        'merge-write does not clobber fields owned by other features',
        () async {
          await firestore.collection('users').doc(userId).set({
            'fcmToken': 'token-abc',
          });

          final repository = FirestoreSettingsRepository(firestore: firestore);
          await repository.updateSettings(userId: userId, settings: settings);

          final snapshot = await firestore
              .collection('users')
              .doc(userId)
              .get();

          expect(snapshot.data()!['fcmToken'], 'token-abc');
          expect(snapshot.data()!['units'], settings.units.name);
        },
      );

      test('also updates the local cache', () async {
        SharedPreferences.setMockInitialValues({});
        final cache = await SharedPreferences.getInstance();

        final repository = FirestoreSettingsRepository(
          firestore: firestore,
          localCache: cache,
        );
        await repository.updateSettings(userId: userId, settings: settings);

        expect(
          cache.getString('settings_cache_$userId'),
          jsonEncode(converter.toMap(settings)),
        );
      });
    });
  });
}
