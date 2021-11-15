import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/models/direction.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/utils/order_detail_bottom.dart';
import 'package:car_app/services/firebase_database_service.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  final Driver? driver;
  const TripDetailScreen({Key? key, required this.trip, this.driver})
      : super(key: key);
  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Marker _origin;
  late Marker _destination;
  late LatLng _start;
  late LatLng _end;
  Direction? _direction;
  bool _isFollowDriver = false;
  Set<Marker> _markers = {};
  Uint8List? _driverMarker;
  final _dbRef = FirebaseDatabaseService.reference;
  LatLng? _driverPosition;
  Completer<GoogleMapController> _controller = Completer();
  String? _destinationAddress;

  _getDirection(LatLng origin, LatLng destination) async {
    _direction = await GeoapifyService.geoRouting(origin.latitude,
        origin.longitude, destination.latitude, destination.longitude);
  }

  Future<void> _getDestinationAddress() async {
    _destinationAddress = (await GeoapifyService.geoReverseGeocoding(
            widget.trip.end_location.lat, widget.trip.end_location.lng))
        ?.address;
  }

  late Widget orderDetailBottom;
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _centerScreen(LatLng? position) async {
    if (position != null) {
      setState(() => _driverPosition = position);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 12.0)));
    }
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
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      position: _start,
    );
    _destination = Marker(
      markerId: MarkerId('destinatinon'),
      infoWindow: InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
      position: _end,
    );
    _getDestinationAddress().whenComplete(() => setState(() {}));
    if (widget.driver != null)
      _dbRef.child('driver/${widget.driver!.id}').onValue.listen((value) {
        if (value.snapshot.value != null &&
            value.snapshot.value['lat'] != null &&
            _isFollowDriver == true) {
          _driverPosition =
              LatLng(value.snapshot.value['lat'], value.snapshot.value['lng']);
          print(_driverPosition!.latitude);
          _centerScreen(_driverPosition);
        }
      });
  }

  _createMarker(LatLng? position, Uint8List? icon) {
    if (position != null && icon != null)
      return Marker(
        markerId: MarkerId('driver'),
        icon: BitmapDescriptor.fromBytes(icon),
        position: position,
      );
  }

  _switchToFollowDriver() {
    setState(() {
      Navigator.of(context).pop();
      _isFollowDriver = !_isFollowDriver;
    });
  }

  @override
  Widget build(BuildContext context) {
    orderDetailBottom = OrderDetailBottom(
      address: _destinationAddress ?? '',
      duration: _direction?.duration,
      distance: _direction?.distance,
      height: 50,
      cabIcon: Icon(Icons.two_wheeler),
      bottomExtend: (widget.driver != null)
          ? ElevatedButton(
              child: _isFollowDriver == true
                  ? Text('Cancel Follow')
                  : Text('Follow Driver'),
              onPressed: () => _switchToFollowDriver(),
            )
          : null,
    );
    getBytesFromAsset('assets/images/driving_pin.png', 100)
        .then((value) => _driverMarker = value);
    GoogleMapController? mapController;
    _markers = {
      _origin,
      _destination,
      if (_createMarker(_driverPosition, _driverMarker) != null)
        _createMarker(_driverPosition, _driverMarker),
    };
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
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
        child: Icon(Icons.pending),
      ),
      body: FutureBuilder<void>(
        future: _getDirection(_start, _end),
        builder: (context, snapshot) {
          return Stack(
            children: [
              Container(
                child: GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  padding: EdgeInsets.only(
                    bottom: 50.0,
                    top: 30,
                  ),
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: _start,
                    zoom: 10.0,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                    mapController = controller;
                    if (_direction != null)
                      WidgetsBinding.instance?.addPostFrameCallback(
                        (_) {
                          mapController?.animateCamera(
                            CameraUpdate.newLatLngBounds(
                                _direction!.bounds, 70),
                          );
                        },
                      );
                  },
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class FollowDriverWidget extends StatefulWidget {
  const FollowDriverWidget({
    Key? key,
    required this.driver,
  }) : super(key: key);
  final Driver driver;
  @override
  _FollowDriverWidgetState createState() => _FollowDriverWidgetState();
}

class _FollowDriverWidgetState extends State<FollowDriverWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: widget.driver.user.avatar_url != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                            widget.driver.user.avatar_url!),
                      )
                    : DecorationImage(
                        image: AssetImage('assets/images/non_avatar.jpg'),
                      ),
              ),
            ),
            title: Text(
              widget.driver.user.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              widget.driver.user.phone,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.phone,
                size: 30,
                color: Colors.indigo[900],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/destination_map_marker.png',
                width: 20,
                height: 20,
              ),
              SizedBox(width: 5),
              Text('Driver is 7 km far from you'),
            ],
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }
}
