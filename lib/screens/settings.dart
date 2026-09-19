import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';
import 'package:world_time/data/world_cities.dart';
import 'package:world_time/models/city.dart';
import 'package:world_time/storage/settings_storage.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onClose;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onClose,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<String> _cityIds;
  late String _compareId;
  late double _transparency;
  late String _sizePreset;
  late bool _alwaysOnDesktop;
  late bool _startWithWindows;

  @override
  void initState() {
    super.initState();
    _cityIds = List.of(widget.settings.cityIds);
    _compareId = widget.settings.compareCityId;
    _transparency = widget.settings.transparency;
    _sizePreset = widget.settings.sizePreset;
    if (_sizePreset != 'S' && _sizePreset != 'M' && _sizePreset != 'L') {
      _sizePreset = 'S';
    }
    if (!_cityIds.contains(_compareId)) {
      _compareId = _cityIds.isNotEmpty ? _cityIds.first : '';
    }
    _alwaysOnDesktop = widget.settings.alwaysOnDesktop;
    _startWithWindows = widget.settings.startWithWindows;
  }

  Future<void> _moveCity(int index, int delta) async {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _cityIds.length) return;
    setState(() {
      final item = _cityIds.removeAt(index);
      _cityIds.insert(newIndex, item);
    });
  }

  Future<void> _removeCity(int index) async {
    setState(() {
      final removed = _cityIds.removeAt(index);
      if (_compareId == removed) {
        _compareId = _cityIds.isNotEmpty ? _cityIds.first : '';
      }
    });
  }

  Future<void> _addCity() async {
    final selected = await showModalBottomSheet<WorldCity>(
      context: context,
      backgroundColor: const Color(0xFF1C1C20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (_) => _AddCitySheet(addedKeys: _cityIds),
    );
    if (selected != null && mounted) {
      setState(() {
        _cityIds.add(selected.key);
        if (_compareId.isEmpty) _compareId = selected.key;
      });
    }
  }

  Future<void> _applySize(String preset) async {
    final size = AppSettings.sizeForPreset(preset);
    setState(() => _sizePreset = preset);
    widget.settings
      ..sizePreset = preset
      ..windowW = size.width
      ..windowH = size.height;
    await windowManager.setSize(size);
    await SettingsStorage.save(widget.settings);
  }

  Future<void> _toggleAlwaysOnDesktop(bool value) async {
    setState(() => _alwaysOnDesktop = value);
    widget.settings.alwaysOnDesktop = value;
    await windowManager.setAlwaysOnBottom(value);
    await SettingsStorage.save(widget.settings);
  }

  Future<void> _toggleStartWithWindows(bool value) async {
    setState(() => _startWithWindows = value);
    widget.settings.startWithWindows = value;
    if (value) {
      await LaunchAtStartup.instance.enable();
    } else {
      await LaunchAtStartup.instance.disable();
    }
    await SettingsStorage.save(widget.settings);
  }

  Future<void> _save() async {
    widget.settings
      ..cityIds = List.of(_cityIds)
      ..compareCityId = _compareId
      ..transparency = _transparency
      ..sizePreset = _sizePreset;
    await SettingsStorage.save(widget.settings);
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(238, 26, 26, 30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: DragToMoveArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Back',
                    ),
                    const Text(
                      '⚙ Settings',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    _sectionTitle('Cities'),
                    const SizedBox(height: 8),
                    if (_cityIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No cities yet. Add one below.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    else
                      ..._cityRows(),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: _addCity,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add City'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size.fromHeight(34),
                    )),
                    const SizedBox(height: 20),
                    _sectionTitle('Compare With'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _compareId,
                      dropdownColor: const Color(0xFF26262B),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: _cityIds.map((key) {
                        final c = cityByKey(key);
                        return DropdownMenuItem(
                          value: key,
                          child: Text(
                            '${c.name}, ${c.country}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _compareId = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Size'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _sizePreset,
                      dropdownColor: const Color(0xFF26262B),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'S', child: Text('Small')),
                        DropdownMenuItem(value: 'M', child: Text('Medium')),
                        DropdownMenuItem(value: 'L', child: Text('Large')),
                      ],
                      onChanged: (value) {
                        if (value != null) _applySize(value);
                      },
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Options'),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      value: _alwaysOnDesktop,
                      onChanged: (v) => _toggleAlwaysOnDesktop(v ?? false),
                      title: const Text('Always on Desktop',
                          style: TextStyle(fontSize: 14)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      value: _startWithWindows,
                      onChanged: (v) => _toggleStartWithWindows(v ?? false),
                      title: const Text('Start with Windows',
                          style: TextStyle(fontSize: 14)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8FE3A8),
                        foregroundColor: const Color(0xFF0B1F12),
                        minimumSize: const Size.fromHeight(38),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.white54,
      ),
    );
  }

  List<Widget> _cityRows() {
    return [
      for (var i = 0; i < _cityIds.length; i++)
        Builder(
          builder: (context) {
            final city = cityByKey(_cityIds[i]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 17, color: Colors.white38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city.country.isEmpty
                          ? city.name
                          : '${city.name}, ${city.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: i == 0 ? null : () => _moveCity(i, -1),
                    icon: const Icon(Icons.keyboard_arrow_up),
                    color: Colors.white54,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Move up',
                  ),
                  IconButton(
                    onPressed: i == _cityIds.length - 1
                        ? null
                        : () => _moveCity(i, 1),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    color: Colors.white54,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Move down',
                  ),
                  IconButton(
                    onPressed: () => _removeCity(i),
                    icon: const Icon(Icons.delete_outline, size: 19),
                    color: Colors.redAccent,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remove',
                  ),
                ],
              ),
            );
          },
        ),
    ];
  }
}

class _AddCitySheet extends StatefulWidget {
  final List<String> addedKeys;

  const _AddCitySheet({required this.addedKeys});

  @override
  State<_AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<_AddCitySheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? worldCities
        : worldCities.where((c) => c.searchKey.contains(q)).toList();
    final visible = results
        .where((c) => !widget.addedKeys.contains(c.key))
        .take(200)
        .toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add City',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search cities… e.g. Kabul, Toronto, Tokyo',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF2A2A30),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching city found.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const Divider(
                            height: 1, color: Colors.white10),
                        itemBuilder: (context, i) {
                          final c = visible[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.public, size: 18, color: Colors.white38),
                            title: Text(
                              c.name,
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              c.country,
                              style: const TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}