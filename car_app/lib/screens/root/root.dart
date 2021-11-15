import 'package:car_app/models/notification.dart';
import 'package:car_app/screens/home/router/home_router.dart';
import 'package:car_app/screens/login/login_screen.dart';
import 'package:car_app/screens/splash_screen/splash_screen.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
// import 'package:car_app/screens/tests_screen/test.dart';

enum AuthStatus {
  unknown,
  loggedIn,
  notLoggedIn,
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  var _authStatus = AuthStatus.unknown;
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  InitializationSettings? initializationSettings;

  _getLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  AndroidNotificationChannel? channel;

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  _createChannel() async => await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

  Future _onSelectNotification(String? payload) async {
    if (payload != null) print(payload);
  }

  _notificationInit() async {
    if (flutterLocalNotificationsPlugin != null &&
        initializationSettings != null) {
      await flutterLocalNotificationsPlugin!.initialize(
        initializationSettings!,
        onSelectNotification: _onSelectNotification,
      );
    }
  }

  _userCancelTripCase(NotificationModel notification) {}
  _driverAcceptTripCase(NotificationModel notification) {
    CurrentTrip currentTrip = Provider.of<CurrentTrip>(context, listen: false);
    var trip = notification.trip;
    currentTrip.removeTrip(trip!);
    currentTrip.addTrip(trip);
  }

  _driverCancelTripCase(NotificationModel notification) {}
  _tripCompletedCase(NotificationModel notification) {
    CurrentTrip currentTrip = Provider.of<CurrentTrip>(context, listen: false);
    var trip = notification.trip;
    currentTrip.removeTrip(trip!);
    setState(() {});
    print(currentTrip.currentTrip);
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (_) => UserCurrentOrder()));
  }

  @override
  void initState() {
    super.initState();
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);

    channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        'This channel is used for Forbiddenimportant notifications.', // description
        importance: Importance.high);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _notificationInit();
    _createChannel();
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        AppleNotification? apple = message.notification?.apple;
        NotificationModel notificationModel =
            await NotificationModel.fromRemoteMessage(message);
        notificationService.addNotification(notificationModel);
        if (notification != null && (android != null || apple != null)) {
          switch (notificationModel.category) {
            case 1:
              _userCancelTripCase(notificationModel);
              break;
            case 2:
              _driverAcceptTripCase(notificationModel);
              break;
            case 3:
              _driverCancelTripCase(notificationModel);
              break;
            case 4:
              _tripCompletedCase(notificationModel);
              break;
            default:
              print(notificationModel.category);
          }
          flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                channel!.description,
                icon: 'launch_background',
              ),
            ),
            payload: message.data.toString(),
          );
        }
      },
    );
    _getLocationPermission();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // get State, check current User, set Auth base
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    int _startupStatus = await _currentUser.onStartup();
    if (_startupStatus == 1) {
      setState(() {
        _authStatus = AuthStatus.loggedIn;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.notLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var router;
    switch (_authStatus) {
      case AuthStatus.loggedIn:
        router = HomeRouter();
        break;
      case AuthStatus.unknown:
        router = SplashScreen();
        break;
      case AuthStatus.notLoggedIn:
        router = LoginScreen();
        // router = TestScreen();
        break;
      default:
    }
    return router;
  }
}
