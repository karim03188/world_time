class WorldCity {
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

  String get searchKey => '$name $country $id'.toLowerCase();
}