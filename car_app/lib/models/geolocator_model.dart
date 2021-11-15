import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorModel with ChangeNotifier {
  Position? _currentLocation;

  get currentLocation => _currentLocation;

  GeolocatorModel() {
    print('GeolocatorModel initialize');
    setCurrentLocation();
  }

  setCurrentLocation() async {
    this._currentLocation = await getCurrentLocation();
    notifyListeners();
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }
}
