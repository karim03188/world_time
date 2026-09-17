import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ClockService {
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      tzdata.initializeTimeZones();
      _initialized = true;
    }
  }

  static tz.TZDateTime now(String tzId) {
    return tz.TZDateTime.now(tz.getLocation(tzId));
  }

  static Duration offset(String tzId) {
    try {
      return tz.getLocation(tzId).currentTimeZone.offset;
    } catch (_) {
      return Duration.zero;
    }
  }

  static String formatOffset(Duration d) {
    final sign = d.isNegative ? '-' : '+';
    final totalMinutes = d.inMinutes.abs();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '$sign${m}m';
    if (m == 0) return '$sign${h}h';
    return '$sign${h}h ${m}m';
  }
}