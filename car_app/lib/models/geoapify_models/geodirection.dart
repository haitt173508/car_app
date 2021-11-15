import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoDirection {
  List<List<LatLng>> coordinates;
  double distance;
  double time;

  GeoDirection({
    required this.coordinates,
    required this.distance,
    required this.time,
  });
}
