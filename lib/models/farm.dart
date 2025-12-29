class Farm {
  int? id;
  String ownerName;
  String farmName;
  String? locationText;
  double? latitude;
  double? longitude;
  String species; // pig, poultry
  int size; // number of animals
  List<String> photos; // list of paths
  int createdBy; // user id

  Farm({
    this.id,
    required this.ownerName,
    required this.farmName,
    this.locationText,
    this.latitude,
    this.longitude,
    required this.species,
    required this.size,
    this.photos = const [],
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_name': ownerName,
      'farm_name': farmName,
      'location_text': locationText,
      'latitude': latitude,
      'longitude': longitude,
      'species': species,
      'size': size,
      'photos': photos.join(','), // store as comma separated
      'created_by': createdBy,
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      id: map['id'],
      ownerName: map['owner_name'],
      farmName: map['farm_name'],
      locationText: map['location_text'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      species: map['species'],
      size: map['size'],
      photos: map['photos'] != null ? (map['photos'] as String).split(',') : [],
      createdBy: map['created_by'],
    );
  }
}