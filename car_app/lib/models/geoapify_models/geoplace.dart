class GeoPlace {
  double lon;
  double lat;
  String? address;
  String? place_id;

  GeoPlace({
    required this.lon,
    required this.lat,
    this.address,
    this.place_id,
  });

  static GeoPlace? fromJson(Map<String, dynamic>? json) {
    if (json == null)
      return null;
    else {
      final data = json['properties'];
      return GeoPlace(
        lat: data['lat'],
        lon: data['lon'],
        address: data['formatted'],
        place_id: data['place_id'],
      );
    }
  }
}
