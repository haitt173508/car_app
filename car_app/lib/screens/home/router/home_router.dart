import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/home/user_home_screen.dart';
import 'package:car_app/screens/home/driver_home_screen.dart';
import 'package:car_app/screens/splash_screen/splash_screen.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

enum UserType {
  unknown,
  user,
  driver,
}

class HomeRouter extends StatefulWidget {
  @override
  _HomeRouterState createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  var _userType = UserType.unknown;


  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    var retVal = _currentUser.getCurrentUser.runtimeType;
    if (retVal == User) {
      setState(() {
        _userType = UserType.user;
      });
    } else if (retVal == Driver) {
      setState(() {
        _userType = UserType.driver;
      });
    } else {
      setState(() {
        _userType = UserType.unknown;
      });
    }
  }

  Future<List<Trip>> _getCurrentOrders(int uid) async {
    return await Api.getCurrentOrders(uid);
  }

  Future<Trip?> _getDriverCurrentTrip(int id) async {
    return Api.getDriverCurrentTrip(id);
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context);
    CurrentTrip _currentTrip = Provider.of<CurrentTrip>(context);
    Widget router = Container();
    switch (_userType) {
      case UserType.user:
        _getCurrentOrders(_currentUser.getCurrentUser.id)
            .then((value) => _currentTrip.onStartupSetCurrentTrip = value);
        router = UserHomeScreen(user: _currentUser.getCurrentUser);
        break;
      case UserType.driver:
        _getDriverCurrentTrip(_currentUser.getCurrentUser.id).then((value) {
          _currentTrip.onStartupSetCurrentTrip = value;
        });
        router = DriverHomeScreen(driver: _currentUser.getCurrentUser);
        break;
      case UserType.unknown:
        router = SplashScreen();
        break;
      default:
    }
    return router;
  }
}
