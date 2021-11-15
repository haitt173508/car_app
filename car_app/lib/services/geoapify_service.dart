import 'dart:convert';
import 'package:car_app/models/direction.dart';
import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:http/http.dart' as http;

class GeoapifyService {
  static const apiKey = '7430b3c955884fa780d1d129af698834';

  static Future<List<GeoPlace?>> geoAutocomplete(String input) async {
    List<GeoPlace?> result = [];
    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=$input&apiKey=$apiKey&lang=vi&filter=countrycode:vn');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      List datas = json.decode(res.body)['features'] as List;
      result = datas.map((e) => GeoPlace.fromJson(e)).toList();
    }
    return result;
  }

  static Future<GeoPlace?> geoReverseGeocoding(double lat, double lon) async {
    GeoPlace? result;
    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lon&lang=vi&apiKey=$apiKey');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var data =
          Map<String, dynamic>.from(json.decode(res.body)['features'][0]);
      result = GeoPlace.fromJson(data);
    }
    return result;
  }

  static geoRouting(double sLat, double sLon, double eLat, double eLon) async {
    final url = Uri.parse(
        'https://api.geoapify.com/v1/routing?waypoints=$sLat,$sLon|$eLat,$eLon&mode=drive&apiKey=$apiKey');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var map = json.decode(res.body);
      var geo = GeoJSONFeature.fromMap(map['features'][0]);
      // print(geo.geometry);
      List<List<double>> coordinates = [
        [sLon, sLat]
      ];
      coordinates.addAll(geo.geometry.toMap()['coordinates'][0]);
      coordinates.forEach((element) {
        var temp = element[0];
        element[0] = element[1];
        element[1] = temp;
      });
      coordinates.add([eLat, eLon]);
      final coords = encodePolyline(coordinates);
      var data = map['features'][0]['properties'];
      var southwest = LatLng(
        map['properties']['waypoints'][0]['lat'],
        map['properties']['waypoints'][0]['lon'],
      );
      var northeast = LatLng(
        map['properties']['waypoints'][1]['lat'],
        map['properties']['waypoints'][1]['lon'],
      );
      if (southwest.latitude > northeast.latitude) {
        LatLng temp = southwest;
        southwest = northeast;
        northeast = temp;
      }

      var bounds = LatLngBounds(
        southwest: southwest,
        northeast: northeast,
      );
      var polyline = PolylinePoints().decodePolyline(coords);
      final time = Duration(seconds: data['time'].toInt());
      String duration = '';
      if (time.inDays != 0) duration = duration + time.inDays.toString() + 'd';
      if (time.inHours != 0)
        duration = duration + time.inHours.remainder(24).toString() + 'h';
      if (time.inMinutes != 0)
        duration = duration + time.inMinutes.remainder(60).toString() + 'mins';
      String distance = '';
      if (data['distance'] < 1000)
        distance = data['distance'].toString() + 'm';
      else
        distance = (data['distance'] / 1000).toString() + 'km';
      return Direction(
        bounds: bounds,
        polyline_points: polyline,
        distance: distance,
        duration: duration,
      );
    }
  }
}
