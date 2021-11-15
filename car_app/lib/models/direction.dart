import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction {
  final LatLngBounds bounds;
  final List<PointLatLng> polyline_points;
  final String distance;
  final String duration;

  Direction({
    required this.bounds,
    required this.polyline_points,
    required this.distance,
    required this.duration,
  });

  static fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('routes')) return null;
    final data = Map<String, dynamic>.from(json['routes'][0]);

    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    final leg = data['legs'][0];
    final String distance = leg['distance']['text'];
    final String duration = leg['duration']['text'];

    return Direction(
        bounds: bounds,
        polyline_points: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        distance: distance,
        duration: duration);
  }
}
