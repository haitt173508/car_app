import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:car_app/apis/api.dart';
import 'package:car_app/models/direction.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/utils/order_detail_bottom.dart';
import 'package:car_app/services/firebase_database_service.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DriverTripDetail extends StatefulWidget {
  final Trip trip;
  final Driver driver;

  const DriverTripDetail({Key? key, required this.trip, required this.driver})
      : super(key: key);
  @override
  _DriverTripDetailState createState() => _DriverTripDetailState();
}

class _DriverTripDetailState extends State<DriverTripDetail> {
  late Marker _origin;
  late Marker _destination;
  late LatLng _start;
  late LatLng _end;
  Direction? _direction;
  Direction? _customerDirection;
  Position? _position;
  bool _visible = true;
  BitmapDescriptor? _markerIcon;
  double _zoom = 10;
  double _bearing = 0.0;
  double _tilt = 60.0;
  Completer<GoogleMapController> _controller = Completer();
  final ref = FirebaseDatabaseService.reference;
  String? _destinationAddress;
  int? _timeCounting;
  String _timeFormatted = '';
  Timer? _timer;
  bool _started = false;
  Trip? _completedTrip;

  _getDirection(LatLng origin, LatLng destination) async {
    _direction = await GeoapifyService.geoRouting(origin.latitude,
        origin.longitude, destination.latitude, destination.longitude);
  }

  _getCustomerDirection(LatLng origin, LatLng destination) async {
    _customerDirection = await GeoapifyService.geoRouting(origin.latitude,
        origin.longitude, destination.latitude, destination.longitude);
  }

  _getCurrentPosition() async {
    print('Getting position');
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    print(_position!.latitude);
  }

  Future<void> _getDestinationAddress() async {
    _destinationAddress = (await GeoapifyService.geoReverseGeocoding(
            widget.trip.end_location.lat, widget.trip.end_location.lng))
        ?.address;
  }

  _startCounting() {
    // var currentTripProvider = Provider.of<CurrentTrip>(context, listen: false);
    // var currentTrip = (widget.trip)..start_time = DateTime.now();
    // currentTripProvider.setCurrentTrip = currentTrip;
    setState(() {
      _completedTrip?.start_time = DateTime.now();
      _started = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _timeCounting = timer.tick;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _start = LatLng(
      widget.trip.start_location.lat,
      widget.trip.start_location.lng,
    );
    _end = LatLng(
      widget.trip.end_location.lat,
      widget.trip.end_location.lng,
    );
    _origin = Marker(
        markerId: MarkerId('origin'),
        infoWindow: InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: _start);
    _destination = Marker(
        markerId: MarkerId('destinatinon'),
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _end);
    _getCurrentPosition();
    _getDestinationAddress().then((value) => setState(() {}));
    _getDirection(_start, _end);
    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.low,
            forceAndroidLocationManager: true)
        .listen((event) {
      ref
          .child('driver/${widget.driver.id}')
          .set({'lat': event.latitude, 'lng': event.longitude});
    });
    _completedTrip = widget.trip;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
      final bool northEastLatitudeCheck =
          screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
      final bool northEastLongitudeCheck =
          screenBounds.northeast.longitude >= fitBounds.northeast.longitude;
      final bool southWestLatitudeCheck =
          screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
      final bool southWestLongitudeCheck =
          screenBounds.southwest.longitude <= fitBounds.southwest.longitude;
      return northEastLatitudeCheck &&
          northEastLongitudeCheck &&
          southWestLatitudeCheck &&
          southWestLongitudeCheck;
    }

    Future<void> zoomToFit(Completer<GoogleMapController> mapController,
        LatLngBounds bounds, LatLng centerBounds) async {
      var controller = await mapController.future;
      bool keepZoomingOut = true;
      while (keepZoomingOut) {
        final LatLngBounds screenBounds = await controller.getVisibleRegion();
        if (fits(bounds, screenBounds)) {
          keepZoomingOut = false;
          final double zoomLevel = await controller.getZoomLevel() - 0.5;
          controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: centerBounds,
                zoom: zoomLevel,
                bearing: _bearing,
                tilt: _tilt,
              ),
            ),
          );
          break;
        } else {
          // Zooming out by 0.1 zoom level per iteration
          final double zoomLevel = await controller.getZoomLevel() - 0.1;
          controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: centerBounds,
                zoom: zoomLevel,
                bearing: _bearing,
                tilt: _tilt,
              ),
            ),
          );
        }
      }
    }

    void _updateBitmap(BitmapDescriptor bitmap) {
      setState(() {
        _markerIcon = bitmap;
      });
    }

    Future<Uint8List> _getBytesFromAsset(String path, int width) async {
      ByteData data = await rootBundle.load(path);
      Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();
    }

    Future<void> _createMarkerImageFromAsset(BuildContext context) async {
      if (_markerIcon == null) {
        _getBytesFromAsset('assets/images/driving_pin.png', 120).then(
          (value) => _updateBitmap(
            BitmapDescriptor.fromBytes(value),
          ),
        );
      }
    }

    Marker _createMarker() {
      if (_markerIcon != null) {
        return Marker(
          markerId: MarkerId("marker_1"),
          position: LatLng(_position!.latitude, _position!.longitude),
          icon: _markerIcon!,
        );
      } else {
        return Marker(
          markerId: MarkerId("marker_1"),
          position: LatLng(_position!.latitude, _position!.longitude),
        );
      }
    }

    Widget _completeTripDialog = AlertDialog(
      title: Text('Done !'),
      content: Text('Conguration !\nYou have done this trip!'),
      actions: [
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text('OK'),
        ),
      ],
    );

    Widget _errorCompleteTripDialog = AlertDialog(
      title: Text('Error occur'),
      content: Text('An error was occur!\nPlease try again!'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    );

    _completeTrip() async {
      _timer?.cancel();
      CurrentTrip currentTripProvider =
          Provider.of<CurrentTrip>(context, listen: false);
      var endTime = DateTime.now();
      setState(() {
        _completedTrip
          ?..end_time = endTime
          ..status = 'Completed';
      });
      var notification = NotificationModel(
        title: 'Your trip was completed',
        body: 'Driver ${widget.driver.user.name} has completed your trip',
        receiver_type: 1,
        receiver: widget.trip.user,
        sender: widget.driver.user.id,
        category: 4,
        trip: _completedTrip,
      );
      var endStatus = await Api.endTrip(currentTripProvider.currentTrip);
      if (endStatus == 'success') {
        await Api.sendNotification(notification);
        showDialog(context: context, builder: (_) => _completeTripDialog);
        currentTripProvider.setCurrentTrip = null;
      } else
        showDialog(context: context, builder: (_) => _errorCompleteTripDialog);
    }

    GoogleMapController? mapController;
    Widget orderDetailBottom = OrderDetailBottom(
      address: _destinationAddress?.substring(0, 20) ?? '',
      duration: _direction?.duration,
      distance: _direction?.distance,
      height: 50,
      cabIcon: Icon(Icons.two_wheeler),
      bottomExtend: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: _started == false ? !_visible : false,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startCounting();
              },
              child: Text('Start'),
            ),
          ),
          Visibility(
            visible: _visible,
            child: ElevatedButton(
              child: Text('Go to customer place'),
              onPressed: () {
                Navigator.of(context).pop();
                mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_position!.latitude, _position!.longitude),
                      zoom: _zoom,
                      tilt: _tilt,
                    ),
                  ),
                );
                _getCustomerDirection(
                        LatLng(_position!.latitude, _position!.longitude),
                        _start)
                    .then((_) {
                  setState(() {
                    _visible = false;
                  });
                  // mapController?.moveCamera(
                  //     CameraUpdate.newLatLngBounds(_customerDirection!.bounds, 70));
                  var bounds = _customerDirection!.bounds;
                  LatLng centerBounds = LatLng(
                      (bounds.northeast.latitude + bounds.southwest.latitude) /
                          2,
                      (bounds.northeast.longitude +
                              bounds.southwest.longitude) /
                          2);
                  mapController?.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: centerBounds,
                        zoom: _zoom,
                        bearing: _bearing,
                        tilt: _tilt,
                      ),
                    ),
                  );
                  zoomToFit(_controller, bounds, centerBounds);
                });
              },
            ),
          ),
          Visibility(
            visible: _started,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () {
                _completeTrip();
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
    _createMarkerImageFromAsset(context);

    void _minusBearing() async {
      var controller = await _controller.future;
      controller
          .animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(_position!.latitude, _position!.longitude),
                bearing: _bearing == 360.0 ? _bearing : _bearing + 45.0,
                zoom: _zoom,
                tilt: _tilt,
              ),
            ),
          )
          .then(
            (value) => setState(() {
              if (_bearing != 360.0) _bearing = _bearing + 45.0;
            }),
          );
    }

    void _addBearing() async {
      var controller = await _controller.future;
      controller
          .animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(_position!.latitude, _position!.longitude),
                  bearing: _bearing == 0.0 ? _bearing : _bearing - 45.0,
                  zoom: _zoom,
                  tilt: _tilt),
            ),
          )
          .then(
            (value) => setState(() {
              print('Current _bearing: $_bearing');
              if (_bearing != 0) _bearing = _bearing - 45.0;
            }),
          );
    }

    if (_timeCounting != null) {
      var duration = Duration(seconds: _timeCounting!);
      _timeFormatted =
          "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_timeFormatted),
        centerTitle: true,
        leading: BackButton(),
        actions: [
          TextButton(
            onPressed: () => _completeTrip(),
            child: Text(
              'Done',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_direction != null)
            mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(_direction!.bounds, 70),
            );
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return orderDetailBottom;
            },
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.pending_outlined),
      ),
      body: FutureBuilder<void>(
        future: _getDirection(_start, _end),
        builder: (context, snapshot) {
          return _position != null
              ? Stack(
                  children: [
                    Container(
                      child: GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        padding: EdgeInsets.only(bottom: 50.0, top: 30),
                        markers: {_origin, _destination, _createMarker()},
                        initialCameraPosition: CameraPosition(
                          tilt: _tilt,
                          bearing: _bearing,
                          target: _start,
                          zoom: _zoom,
                        ),
                        onCameraMove: (position) {
                          if (_zoom != position.zoom)
                            setState(() => _zoom = position.zoom);
                        },
                        onMapCreated: (controller) {
                          mapController = controller;
                          _controller.complete(controller);
                          if (_direction != null)
                            WidgetsBinding.instance?.addPostFrameCallback((_) {
                              mapController?.animateCamera(
                                  CameraUpdate.newLatLngBounds(
                                      _direction!.bounds, 70));
                            });
                        },
                        polylines: {
                          if (_direction != null)
                            Polyline(
                              polylineId: PolylineId('overview_polyline'),
                              color: Colors.redAccent,
                              width: 3,
                              points: _direction!.polyline_points
                                  .map((e) => LatLng(e.latitude, e.longitude))
                                  .toList(),
                            ),
                          if (_customerDirection != null)
                            Polyline(
                              polylineId: PolylineId('customer_polyline'),
                              color: Colors.blue,
                              width: 2,
                              points: _customerDirection!.polyline_points
                                  .map((e) => LatLng(e.latitude, e.longitude))
                                  .toList(),
                            ),
                        },
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                        ),
                        onPressed: () => _addBearing(),
                        child: Icon(
                          Icons.rotate_right,
                          size: 25,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: CircleBorder(),
                        ),
                        onPressed: () => _minusBearing(),
                        child: Icon(
                          Icons.rotate_left,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
