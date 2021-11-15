import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var api = Api();
var storage = FlutterSecureStorage();

class CurrentUser with ChangeNotifier {
  var _currentUser;
  void set currentUser(user) {
    _currentUser = user;
  }

  get getCurrentUser => _currentUser;

  login(username, password, userType) async {
    String retVal = 'success';
    Map<String, dynamic> data =
        await api.loginWithUsernameAndPassword(username, password);
    if (data['message'] != null)
      retVal = data['message'];
    else {
      data.forEach((key, value) => storage.write(key: key, value: value));
      User? user;
      user = await api.getUserFromToken(data['access_token']);
      if (user != null) {
        await storage.write(key: 'user_type', value: userType.toString());
        if (userType == 1) {
          _currentUser = user;
          // await api.setUserOfToken(user, 1);
        } else {
          Driver? driver;
          driver = await api.getLogginDriver(user.id!);
          _currentUser = driver;
          if (driver == null) {
            await storage.deleteAll();
            retVal = 'You are not a driver or wrong username or password';
          } else {
            // await api.setUserOfToken(user, 2);
          }
        }
      } else {
        await storage.deleteAll();
        retVal = 'Error occur';
      }
    }
    return retVal;
  }

  logout() async {
    _currentUser = null;
    await storage.deleteAll();
    await api.deleteFCMToken();
  }

  onStartup() async {
    String? token;
    token = await storage.read(key: 'access_token');
    String? userType;
    userType = await storage.read(key: 'user_type');
    if (token == null) {
      _currentUser == null;
    } else {
      User? user;
      user = await api.getUserFromToken(token);
      if (user == null) {
        _currentUser = null;
      } else {
        if (userType == '1') {
          _currentUser = user;
          await api.setUserOfToken(user, 1);
        } else if (userType == '2') {
          Driver? driver;
          driver = await api.getLogginDriver(user.id!);
          _currentUser = driver;
          if (driver == null)
            await storage.deleteAll();
          else {
            await api.setUserOfToken(user, 2);
          }
        }
      }
    }

    if (_currentUser == null) {
      return 0;
    } else {
      return 1;
    }
  }
}
