import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_time/data/world_cities.dart';

class AppSettings {
  /// Each entry is a [WorldCity.key] (not a raw IANA time zone id — several
  /// cities can share one time zone, so the key also encodes the city name).
  List<String> cityIds;
  String compareCityId;
  double transparency;
  String sizePreset;
  bool alwaysOnDesktop;
  bool startWithWindows;
  double? windowX;
  double? windowY;
  double? windowW;
  double? windowH;

  AppSettings({
    required this.cityIds,
    required this.compareCityId,
    this.transparency = 0.65,
    this.sizePreset = 'S',
    this.alwaysOnDesktop = false,
    this.startWithWindows = true,
    this.windowX,
    this.windowY,
    this.windowW,
    this.windowH,
  });

  Offset? get windowPosition =>
      (windowX != null && windowY != null) ? Offset(windowX!, windowY!) : null;

  static Size sizeForPreset(String preset) {
    switch (preset) {
      case 'S':
        return const Size(320, 400);
      case 'M':
        return const Size(400, 520);
      case 'L':
        return const Size(520, 660);
      default:
        return const Size(340, 450);
    }
  }

  Size get resolvedSize {
    if (windowW != null && windowH != null) return Size(windowW!, windowH!);
    return sizeForPreset(sizePreset);
  }

  int get bgAlpha => (transparency * 255).clamp(20, 245).round();
}

class SettingsStorage {
  static const _kCities = 'cities';
  static const _kCompare = 'compare';
  static const _kTransparency = 'transparency';
  static const _kSizePreset = 'sizePreset';
  static const _kAlwaysOnDesktop = 'alwaysOnDesktop';
  static const _kStartWithWindows = 'startWithWindows';
  static const _kWindowX = 'windowX';
  static const _kWindowY = 'windowY';
  static const _kWindowW = 'windowW';
  static const _kWindowH = 'windowH';

  static final defaultCities = <String>[
    cityByTzId('Asia/Kabul').key,
    cityByTzId('America/Toronto').key,
    cityByTzId('America/Vancouver').key,
    cityByTzId('Europe/London').key,
  ];

  /// Converts a saved city entry to the current [WorldCity.key] format.
  /// Settings saved before city keys existed stored a raw IANA time zone id
  /// (no '|'); map those to that zone's first catalog entry so upgrading
  /// users don't lose their saved cities.
  static String _migrateCityEntry(String saved) {
    if (saved.contains('|')) return saved;
    return cityByTzId(saved).key;
  }

  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final savedCities = p.getStringList(_kCities);
    final cities = savedCities == null
        ? defaultCities
        : savedCities.map(_migrateCityEntry).toList();
    var compare = p.getString(_kCompare);
    compare = compare == null ? null : _migrateCityEntry(compare);
    if (compare == null || !cities.contains(compare)) {
      compare = cities.isNotEmpty ? cities.first : '';
    }
    return AppSettings(
      cityIds: cities,
      compareCityId: compare,
      transparency: p.getDouble(_kTransparency) ?? 0.65,
      sizePreset: p.getString(_kSizePreset) ?? 'S',
      alwaysOnDesktop: p.getBool(_kAlwaysOnDesktop) ?? false,
      startWithWindows: p.getBool(_kStartWithWindows) ?? true,
      windowX: p.getDouble(_kWindowX),
      windowY: p.getDouble(_kWindowY),
      windowW: p.getDouble(_kWindowW),
      windowH: p.getDouble(_kWindowH),
    );
  }

  static Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kCities, s.cityIds);
    await p.setString(_kCompare, s.compareCityId);
    await p.setDouble(_kTransparency, s.transparency);
    await p.setString(_kSizePreset, s.sizePreset);
    await p.setBool(_kAlwaysOnDesktop, s.alwaysOnDesktop);
    await p.setBool(_kStartWithWindows, s.startWithWindows);
    if (s.windowX != null) await p.setDouble(_kWindowX, s.windowX!);
    if (s.windowY != null) await p.setDouble(_kWindowY, s.windowY!);
    if (s.windowW != null) await p.setDouble(_kWindowW, s.windowW!);
    if (s.windowH != null) await p.setDouble(_kWindowH, s.windowH!);
  }
}