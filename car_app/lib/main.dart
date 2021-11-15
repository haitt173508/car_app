import 'package:car_app/models/geolocator_model.dart';
import 'package:car_app/screens/root/root.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:car_app/services/place_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationService>(
          create: (context) => NotificationService(),
        ),
        ChangeNotifierProvider<CurrentUser>(create: (context) => CurrentUser()),
        ChangeNotifierProvider<GeolocatorModel>(
            create: (context) => GeolocatorModel()),
        ChangeNotifierProvider<PlaceService>(
            create: (context) => PlaceService()),
        ChangeNotifierProvider<CurrentTrip>(create: (context) => CurrentTrip()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.redAccent,
        ),
        debugShowCheckedModeBanner: false,
        home: Root(),
        // home: TestScreen(),
      ),
    );
  }
}

// class TestScreen extends StatefulWidget {
//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   late Position _position;
//   BitmapDescriptor? _markerIcon;
//   Completer<GoogleMapController> _controller = Completer();
//   var _initialCameraPosition;
//   Direction? _direction;
//   final _start = LatLng(20.6129463, 105.73676560000001);
//   final _end = LatLng(20.68391160198584, 105.73676560000001);

//   Future<void> centerScreen(Position position) async {
//     final GoogleMapController controller = await _controller.future;
//     setState(() => _position = position);
//     controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//         target: LatLng(position.latitude, position.longitude), zoom: 12.0)));
//   }

//   void _updateBitmap(BitmapDescriptor bitmap) {
//     setState(() {
//       _markerIcon = bitmap;
//     });
//   }

//   Future<Uint8List> _getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
//         targetWidth: width);
//     FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }

//   Future<void> _createMarkerImageFromAsset(BuildContext context) async {
//     if (_markerIcon == null) {
//       _getBytesFromAsset('assets/images/driving_pin.png', 40).then(
//         (value) => _updateBitmap(
//           BitmapDescriptor.fromBytes(value),
//         ),
//       );
//     }
//   }

//   Marker _createMarker() {
//     if (_markerIcon != null) {
//       return Marker(
//         markerId: MarkerId("marker_1"),
//         position: LatLng(_position.latitude, _position.longitude),
//         icon: _markerIcon!,
//       );
//     } else {
//       return Marker(
//         markerId: MarkerId("marker_1"),
//         position: LatLng(_position.latitude, _position.longitude),
//       );
//     }
//   }

//   _getDirection(LatLng origin, LatLng destination) async {
//     _direction = await GeoapifyService.geoRouting(origin.latitude,
//         origin.longitude, destination.latitude, destination.longitude);
//   }

//   // _getPosition() async {

//   // }

//   @override
//   void initState() {
//     _getDirection(_start, _end);
//     _createMarkerImageFromAsset(context);
//     Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.low,
//       forceAndroidLocationManager: true,
//     ).then((value) {
//       _position = value;
//       _initialCameraPosition = CameraPosition(
//           target: LatLng(_position.latitude, _position.longitude), zoom: 15);
//     });
//     Geolocator.getPositionStream(
//             desiredAccuracy: LocationAccuracy.low,
//             forceAndroidLocationManager: true)
//         .listen((position) {
//       centerScreen(position);
//       // _sendPosition();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     GoogleMapController? mapController;
//     return Stack(
//       children: [
//         GoogleMap(
//             markers: {_createMarker()},
//             myLocationEnabled: true,
//             initialCameraPosition: _initialCameraPosition,
//             onMapCreated: (controller) {
//               _controller.complete(controller);
//               mapController = controller;
//               if (_direction != null)
//                 WidgetsBinding.instance?.addPostFrameCallback((_) {
//                   mapController?.animateCamera(
//                       CameraUpdate.newLatLngBounds(_direction!.bounds, 70));
//                 });
//             },
//             polylines: {
//               if (_direction != null)
//                 Polyline(
//                   polylineId: PolylineId('overview_polyline'),
//                   color: Colors.redAccent,
//                   width: 3,
//                   points: _direction!.polyline_points
//                       .map((e) => LatLng(e.latitude, e.longitude))
//                       .toList(),
//                 ),
//             }),
//       ],
//     );
//   }
// }
