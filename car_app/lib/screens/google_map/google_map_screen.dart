import 'dart:async';
import 'package:car_app/models/direction.dart';
import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:car_app/services/place_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription<GeoPlace?> _streamSubscription;
  late PlaceService _placeService;
  Marker? _origin;
  Marker? _destination;
  Direction? _direction;
  CameraPosition? _initCameraPosition;
  GoogleMapController? _controller;
  // String? _mapStyle;

  Future<void> _goToPlace(GeoPlace place) async {
    var mapController = await _mapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        place.lat,
        place.lon,
      ),
      zoom: 12,
    )));
  }

  Future<void> _getCurrentPosition() async {
    Position _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    _initCameraPosition = CameraPosition(
      target: LatLng(_position.latitude, _position.longitude),
      zoom: 12,
    );
  }

  @override
  void initState() {
    _getCurrentPosition();
    _placeService = Provider.of<PlaceService>(context, listen: false);
    _streamSubscription =
        _placeService.selectedGeoPlace.listen((GeoPlace? place) {
      if (place != null) _goToPlace(place);
    });
    // rootBundle.loadString('assets/map_style/map_style.txt').then((string) {
    //   _mapStyle = string;
    // });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    PlaceService _placeService = Provider.of<PlaceService>(context);
    _origin = _placeService.origin;
    _destination = _placeService.destination;
    _direction = _placeService.direction;

    return Container(
      child: _initCameraPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: _initCameraPosition!,
                  markers: {
                    if (_origin != null) _origin!,
                    if (_destination != null) _destination!,
                  },
                  // onLongPress: _placeService.addMarker,
                  myLocationEnabled: true,
                  onMapCreated: (controller) {
                    _controller = controller;
                    // _controller?.setMapStyle(_mapStyle);
                    _mapController.complete(controller);
                  },
                  zoomControlsEnabled: true,
                  padding: EdgeInsets.only(
                    bottom: 50.0,
                    top: 30,
                  ),
                  polylines: {
                    if (_direction != null)
                      Polyline(
                        polylineId: PolylineId('overview_polyline'),
                        color: Colors.redAccent,
                        width: 2,
                        points: _direction!.polyline_points
                            .map((e) => LatLng(e.latitude, e.longitude))
                            .toList(),
                      ),
                  },
                ),
                if (_direction != null)
                  Positioned(
                    top: 20.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Text(
                        'time: ${_direction!.duration}, distance: ${_direction!.distance}',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 5,
                  right: 10,
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      _controller?.animateCamera(
                        _direction != null
                            ? CameraUpdate.newLatLngBounds(
                                _direction!.bounds, 80.0)
                            : CameraUpdate.newCameraPosition(
                                _initCameraPosition!),
                      );
                    },
                    child: Icon(Icons.center_focus_strong),
                  ),
                )
              ],
            ),
    );
  }

  // void _addMarker(LatLng pos) async {
  //   if (_origin == null || (_origin != null && _destination != null)) {
  //     setState(() {
  //       _origin = Marker(
  //         markerId: MarkerId('origtin'),
  //         infoWindow: InfoWindow(title: 'Origin'),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(
  //           BitmapDescriptor.hueGreen,
  //         ),
  //         position: pos,
  //       );
  //       _destination = null;
  //       _direction = null;
  //     });
  //   } else {
  //     setState(() {
  //       _destination = Marker(
  //         markerId: MarkerId('destination'),
  //         infoWindow: InfoWindow(title: 'Destination'),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(
  //           BitmapDescriptor.hueBlue,
  //         ),
  //         position: pos,
  //       );
  //     });
  //     final direction = await _placeService.getDirection(
  //       origin: _origin!.position,
  //       destination: pos,
  //     );
  //     setState(() {
  //       _direction = direction;
  //     });
  //   }
  // }
}
