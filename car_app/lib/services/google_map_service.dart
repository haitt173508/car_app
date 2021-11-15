import 'dart:convert';

import 'package:car_app/models/direction.dart';
import 'package:car_app/models/geocode.dart';
import 'package:car_app/models/place_detail.dart';
import 'package:car_app/models/place_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapService with ChangeNotifier {
  static const key = "AIzaSyCmAUhuDeHY3HjgwKLdvm0rpsoyS6JmF9U";
  // static const apiKey = "AIzaSyCJqpC7oo-YYJJ1pRVZJgf84qExlHZCWSc";
  static const dirApiKey = "AIzaSyA66KwUrjxcFG5u0exynlJ45CrbrNe3hEc";
  static const apiKey = "AIzaSyA66KwUrjxcFG5u0exynlJ45CrbrNe3hEc";

  static Future<List<PlaceSearch>> getPlaceAutocomplete(String search) async {
    final String key = apiKey;
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=geocode&language=vi&key=$key&components%3Dcountry:=vi');
    var response = await http.get(url);
    var jsonData = json.decode(response.body);
    var places = jsonData['predictions'] as List;
    List<PlaceSearch> results =
        places.map((place) => PlaceSearch.fromJson(place)).toList();
    return results;
  }

  static Future<PlaceDetail> getPlaceDetail(String placeId) async {
    final String key = apiKey;
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key');
    var reponse = await http.get(url);
    var jsonData = json.decode(reponse.body);
    var place = jsonData['result'] as Map<String, dynamic>;
    PlaceDetail result = PlaceDetail.fromJson(place);
    return result;
  }

  static Future<GeoCode> getReverseGeocoding(LatLng latlng) async {
    final String key = apiKey;
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latlng.latitude},${latlng.longitude}&language=vi&key=$key');
    var response = await http.get(url);
    var jsonData = json.decode(response.body);
    var results = jsonData['results'] as List;
    GeoCode result = GeoCode.fromJson(results[0]);
    return result;
  }

  static Future<Direction?> getDirection(
      {required LatLng origin, required LatLng destination}) async {
    // final String key = dirApiKey;
    // var url = Uri.parse(
    //     'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$key');
    // var response = await http.get(url);
    // var jsonData = json.decode(response.body);
    var jsonText = await rootBundle.loadString('assets/response.json');
    var jsonData = json.decode(jsonText);
    Direction? result;
    result = Direction.fromJson(jsonData);
    return result;
  }
}
