import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_time/data/world_cities.dart';
import 'package:world_time/storage/settings_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppSettings', () {
    test('resolvedSize falls back to the size preset when no saved size', () {
      final s = AppSettings(cityIds: const [], compareCityId: '');
      expect(s.resolvedSize, AppSettings.sizeForPreset('S'));
    });

    test('resolvedSize prefers an explicit saved window size', () {
      final s = AppSettings(
        cityIds: const [],
        compareCityId: '',
        windowW: 500,
        windowH: 600,
      );
      expect(s.resolvedSize.width, 500);
      expect(s.resolvedSize.height, 600);
    });

    test('bgAlpha clamps transparency into a valid alpha range', () {
      final tooLow = AppSettings(
        cityIds: const [],
        compareCityId: '',
        transparency: 0,
      );
      final tooHigh = AppSettings(
        cityIds: const [],
        compareCityId: '',
        transparency: 1,
      );
      expect(tooLow.bgAlpha, 20);
      expect(tooHigh.bgAlpha, 245);
    });

    test('windowPosition is null unless both x and y are set', () {
      final s = AppSettings(cityIds: const [], compareCityId: '', windowX: 10);
      expect(s.windowPosition, isNull);
    });
  });

  group('SettingsStorage', () {
    test('load returns sane defaults on first run', () async {
      final s = await SettingsStorage.load();
      expect(s.cityIds, SettingsStorage.defaultCities);
      expect(s.compareCityId, cityByTzId('Asia/Kabul').key);
      expect(s.startWithWindows, isTrue);
    });

    test('load migrates legacy raw-timezone entries to the key format', () async {
      // Settings saved before city keys existed stored a raw IANA time zone
      // id with no cities sharing that zone in the picked set.
      SharedPreferences.setMockInitialValues({
        'cities': ['Europe/London'],
        'compare': 'Europe/London',
      });
      final s = await SettingsStorage.load();
      expect(s.cityIds, [cityByTzId('Europe/London').key]);
      expect(s.compareCityId, cityByTzId('Europe/London').key);
    });

    test(
        'two cities sharing one time zone are both kept and independently '
        'selectable, unlike the legacy raw-timezone-id format', () async {
      final newYork = cityByTzId('America/New_York').key;
      final dc = worldCities
          .firstWhere((c) => c.id == 'America/New_York' && c.name != 'New York')
          .key;
      SharedPreferences.setMockInitialValues({
        'cities': [newYork, dc],
        'compare': dc,
      });
      final s = await SettingsStorage.load();
      expect(s.cityIds, [newYork, dc]);
      expect(newYork == dc, isFalse);
      expect(s.compareCityId, dc);
    });

    test('load resets compareCityId when it is no longer in cityIds', () async {
      final london = cityByTzId('Europe/London').key;
      SharedPreferences.setMockInitialValues({
        'cities': [london],
        'compare': cityByTzId('Asia/Kabul').key,
      });
      final s = await SettingsStorage.load();
      expect(s.compareCityId, london);
    });

    test('save persists values that load then reads back', () async {
      final london = cityByTzId('Europe/London').key;
      final tokyo = cityByTzId('Asia/Tokyo').key;
      final s = AppSettings(
        cityIds: [london, tokyo],
        compareCityId: tokyo,
        transparency: 0.5,
        sizePreset: 'L',
        alwaysOnDesktop: true,
        startWithWindows: false,
        windowX: 12,
        windowY: 34,
        windowW: 400,
        windowH: 500,
      );
      await SettingsStorage.save(s);

      final reloaded = await SettingsStorage.load();
      expect(reloaded.cityIds, s.cityIds);
      expect(reloaded.compareCityId, s.compareCityId);
      expect(reloaded.transparency, 0.5);
      expect(reloaded.sizePreset, 'L');
      expect(reloaded.alwaysOnDesktop, isTrue);
      expect(reloaded.startWithWindows, isFalse);
      expect(reloaded.windowPosition, const Offset(12, 34));
    });
  });
}
