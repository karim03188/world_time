import 'package:flutter_test/flutter_test.dart';
import 'package:world_time/services/clock_service.dart';

void main() {
  setUpAll(ClockService.init);

  group('ClockService.formatOffset', () {
    test('formats a positive whole-hour offset', () {
      expect(ClockService.formatOffset(const Duration(hours: 4)), '+4h');
    });

    test('formats a negative whole-hour offset', () {
      expect(ClockService.formatOffset(const Duration(hours: -5)), '-5h');
    });

    test('formats a half-hour offset', () {
      expect(
        ClockService.formatOffset(const Duration(hours: 5, minutes: 30)),
        '+5h 30m',
      );
    });

    test('formats a sub-hour-only offset', () {
      expect(ClockService.formatOffset(const Duration(minutes: -45)), '-45m');
    });

    test('formats a zero offset as positive', () {
      expect(ClockService.formatOffset(Duration.zero), '+0m');
    });
  });

  group('ClockService.now / offset', () {
    test('returns the current time in the requested IANA zone', () {
      final tokyo = ClockService.now('Asia/Tokyo');
      final utc = ClockService.now('Etc/UTC');
      // Tokyo has no DST, so it is always exactly 9 hours ahead of UTC.
      expect(tokyo.timeZoneOffset.inHours, 9);
      expect(
        tokyo.difference(utc).inMinutes.abs() < 2,
        isTrue,
        reason: 'Tokyo and UTC clocks should be within a couple minutes '
            'of each other once the +9h offset is accounted for',
      );
    });

    test('falls back to zero offset for an unknown zone id', () {
      expect(ClockService.offset('Not/A_Real_Zone'), Duration.zero);
    });
  });
}
