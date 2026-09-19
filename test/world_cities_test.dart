import 'package:flutter_test/flutter_test.dart';
import 'package:world_time/data/world_cities.dart';

void main() {
  group('WorldCity.key', () {
    test('every catalog entry has a unique key', () {
      final keys = worldCities.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length,
          reason: 'Duplicate WorldCity.key values would make two different '
              'cities indistinguishable once saved to settings.');
    });
  });

  group('cityByKey', () {
    test('resolves two cities that share a time zone to their own identity',
        () {
      // New York and Washington D.C. both use America/New_York.
      final newYork = worldCities.firstWhere(
        (c) => c.id == 'America/New_York' && c.name == 'New York',
      );
      final dc = worldCities.firstWhere(
        (c) => c.id == 'America/New_York' && c.name == 'Washington D.C.',
      );

      expect(cityByKey(newYork.key).name, 'New York');
      expect(cityByKey(dc.key).name, 'Washington D.C.');
    });

    test('falls back to a synthetic city for an unknown key', () {
      final c = cityByKey('Not/A_Real_Zone|Nowhere');
      expect(c.id, 'Not/A_Real_Zone');
    });
  });

  group('cityByTzId', () {
    test('returns the first catalog match for a shared time zone', () {
      expect(cityByTzId('America/New_York').name, 'New York');
    });
  });
}
