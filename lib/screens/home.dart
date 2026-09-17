import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';
import 'package:world_time/data/world_cities.dart';
import 'package:world_time/services/clock_service.dart';
import 'package:world_time/storage/settings_storage.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.onOpenSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 380).clamp(0.72, 1.15);

    return DragToResizeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromARGB(s.bgAlpha, 18, 18, 22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: DragToMoveArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 17,
                      color: Color(0xFF8FE3A8),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'World Clock',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onOpenSettings,
                      icon: const Icon(Icons.settings_outlined,
                          size: 18, color: Colors.white60),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Settings',
                    ),
                  ],
                ),
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 10),
                Expanded(
                  child: _CityList(settings: s, scale: scale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityList extends StatelessWidget {
  final AppSettings settings;
  final double scale;

  const _CityList({required this.settings, required this.scale});

  @override
  Widget build(BuildContext context) {
    final compareOffset = ClockService.offset(settings.compareCityId);

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: settings.cityIds.length,
      separatorBuilder: (_, _) => const Divider(height: 20, color: Colors.white10),
      itemBuilder: (context, index) {
        final id = settings.cityIds[index];
        final city = cityByTzId(id);
        final now = ClockService.now(id);
        final isRef = id == settings.compareCityId;
        final diff = ClockService.offset(id) - compareOffset;

        final status = isRef
            ? 'Reference'
            : ClockService.formatOffset(diff);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(city.flag, style: TextStyle(fontSize: 26 * scale)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.country.isEmpty
                        ? city.name
                        : '${city.name}, ${city.country}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5 * scale,
                      fontWeight: FontWeight.w600,
                      color: isRef ? const Color(0xFF8FE3A8) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.5 * scale,
                      color: isRef ? const Color(0xFF8FE3A8).withValues(alpha: 0.8) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('h:mm a').format(now),
                  style: TextStyle(
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '${now.second.toString().padLeft(2, '0')}s',
                  style: TextStyle(
                    fontSize: 10.5 * scale,
                    color: Colors.white38,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}