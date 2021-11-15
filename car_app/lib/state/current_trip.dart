import 'package:car_app/models/trip.dart';
import 'package:flutter/material.dart';

class CurrentTrip with ChangeNotifier {
  var _currentTrip;

  get currentTrip => _currentTrip;

  set onStartupSetCurrentTrip(input) {
    _currentTrip = input;
  }

  set setCurrentTrip(Trip? trip) {
    _currentTrip = trip;
    notifyListeners();
  }

  addTrip(Trip trip) {
    _currentTrip.add(trip);
    notifyListeners();
  }

  removeTrip(Trip trip) {
    _currentTrip.removeWhere((e) => e.id == trip.id);
    notifyListeners();
  }
}
