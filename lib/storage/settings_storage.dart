import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
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

  static const defaultCities = <String>[
    'Asia/Kabul',
    'America/Toronto',
    'America/Vancouver',
    'Europe/London',
  ];

  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final cities = p.getStringList(_kCities) ?? defaultCities;
    var compare = p.getString(_kCompare) ?? 'Asia/Kabul';
    if (!cities.contains(compare)) {
      compare = cities.isNotEmpty ? cities.first : 'Asia/Kabul';
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