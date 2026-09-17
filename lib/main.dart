import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';
import 'package:world_time/screens/home.dart';
import 'package:world_time/screens/settings.dart';
import 'package:world_time/services/clock_service.dart';
import 'package:world_time/storage/settings_storage.dart';

late AppSettings appSettings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ClockService.init();
  await windowManager.ensureInitialized();
  appSettings = await SettingsStorage.load();
  await _initWindow();
  runApp(const WorldClockApp());
}

Future<void> _initWindow() async {
  LaunchAtStartup.instance.setup(
    appName: 'World Clock',
    appPath: Platform.resolvedExecutable,
  );
  if (appSettings.startWithWindows) {
    await LaunchAtStartup.instance.enable();
  } else {
    await LaunchAtStartup.instance.disable();
  }

  final size = appSettings.resolvedSize;
  final options = WindowOptions(
    size: size,
    center: appSettings.windowPosition == null,
    minimumSize: const Size(280, 180),
    maximumSize: const Size(900, 1400),
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    skipTaskbar: true,
    title: 'World Clock',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    final pos = appSettings.windowPosition;
    if (pos != null) {
      await windowManager.setPosition(pos);
    }
    await windowManager.setAlwaysOnBottom(appSettings.alwaysOnDesktop);
    await windowManager.setHasShadow(false);
    await windowManager.show();
    await windowManager.focus();
  });

  // Transparent windows on Windows may render a black first frame; this nudges a redraw.
  final current = await windowManager.getSize();
  await windowManager.setSize(Size(current.width + 1, current.height + 1));
  await windowManager.setSize(current);
}

class WorldClockApp extends StatefulWidget {
  const WorldClockApp({super.key});

  @override
  State<WorldClockApp> createState() => _WorldClockAppState();
}

class _WorldClockAppState extends State<WorldClockApp> {
  bool _showSettings = false;
  final _listener = _PersistenceListener();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(_listener);
  }

  @override
  void dispose() {
    windowManager.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8FE3A8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        dividerColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _showSettings
            ? SettingsScreen(
                settings: appSettings,
                onClose: () => setState(() => _showSettings = false),
              )
            : HomeScreen(
                settings: appSettings,
                onOpenSettings: () => setState(() => _showSettings = true),
              ),
      ),
    );
  }
}

class _PersistenceListener with WindowListener {
  @override
  void onWindowMoved() async {
    final pos = await windowManager.getPosition();
    appSettings
      ..windowX = pos.dx
      ..windowY = pos.dy;
    await SettingsStorage.save(appSettings);
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    appSettings
      ..windowW = size.width
      ..windowH = size.height;
    await SettingsStorage.save(appSettings);
  }
}