class WorldCity {
  /// IANA time zone identifier (e.g. 'America/New_York'). Multiple cities can
  /// share the same [id] when they share a time zone (e.g. New York and
  /// Washington D.C.), so this must never be used as a unique key.
  final String id;
  final String name;
  final String country;
  final String flag;

  const WorldCity({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
  });

  /// Stable unique identity for this city entry, distinct from [id] since
  /// several cities can share one time zone. Used for storage and list keys.
  String get key => '$id|$name';

  String get searchKey => '$name $country $id'.toLowerCase();
}