import 'dart:async';
import 'package:car_app/models/direction.dart';
import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:car_app/models/place_detail.dart';
import 'package:car_app/models/place_search.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:car_app/services/google_map_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceService with ChangeNotifier {
  List<PlaceSearch> _searchResults = <PlaceSearch>[];
  List<GeoPlace?> _geoSearchResult = [];
  get geoSearchResult => _geoSearchResult;
  set geoSearchResult(result) => _geoSearchResult = result;
  final apiKey = GoogleMapService.apiKey;
  final dirApiKey = GoogleMapService.dirApiKey;
  StreamController<PlaceDetail?> _selectedPlace =
      StreamController<PlaceDetail?>.broadcast();
  StreamController<GeoPlace?> _selectedGeoPlace =
      StreamController<GeoPlace?>.broadcast();
  Stream<PlaceDetail?> get selectedPlace => _selectedPlace.stream;
  Stream<GeoPlace?> get selectedGeoPlace => _selectedGeoPlace.stream;
  Marker? _origin;
  Marker? _destination;
  Direction? _direction;

  Marker? get origin => _origin;
  Marker? get destination => _destination;
  Direction? get direction => _direction;

  set origin(arg) => this._origin = arg;
  set destination(arg) => this._destination = arg;
  set direction(arg) => this._direction = arg;
  // late GeoCode _geoCodeResult;

  // GeoCode get geoCodeResult => _geoCodeResult;
  List<PlaceSearch> get searchResults => _searchResults;
  void set searchResults(results) => _searchResults = results;

  Future<void> setSearchResults(String searchTerm) async {
    List<PlaceSearch> results =
        await GoogleMapService.getPlaceAutocomplete(searchTerm);
    this._searchResults = results;
    notifyListeners();
  }

  setGeoSearchResult(String input) async {
    List<GeoPlace?> result = await GeoapifyService.geoAutocomplete(input);
    geoSearchResult = result;
    notifyListeners();
  }

  Future<void> setSelectedPlace(PlaceDetail place) async {
    _selectedPlace.add(place);
    notifyListeners();
    _searchResults.clear();
  }

  Future<void> setSelectedGeoPlace(GeoPlace? place) async {
    _selectedGeoPlace.add(place);
    notifyListeners();
    _geoSearchResult.clear();
  }

  void addMarker(LatLng pos, String mark) async {
    if (mark == 'start') {
      _origin = Marker(
        markerId: MarkerId('origin'),
        infoWindow: InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        position: pos,
      );
      // _destination = null;
      // _direction = null;
    } else if (mark == 'end') {
      _destination = Marker(
        markerId: MarkerId('destination'),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        position: pos,
      );
    }
    if (_origin != null && _destination != null) {
      // final direction = await GoogleMapService.getDirection(
      //   origin: _origin!.position,
      //   destination: _destination!.position,
      // );
      // _direction = direction;
      final direction = await GeoapifyService.geoRouting(
        _origin!.position.latitude,
        _origin!.position.longitude,
        _destination!.position.latitude,
        _destination!.position.longitude,
      );
      _direction = direction;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedPlace.close();
    super.dispose();
  }
}
