import 'dart:convert';
import 'dart:io';
import 'package:car_app/models/FCMDevice.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/services/http_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

FlutterSecureStorage storage = FlutterSecureStorage();

class Api {
  loginWithUsernameAndPassword(username, password) async {
    final url = HttpService.baseUrl + "login/";
    Uri uri = Uri.parse(url);
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    var data = json.decode(response.body);
    return data;
  }

  Future<String> signup(user) async {
    final url = HttpService.baseUrl + 'user/';
    Uri uri = Uri.parse(url);
    var retVal = 'success';
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    print(user.toJson());
    final data = json.decode(response.body);
    retVal = data['message'];
    print(data);
    return retVal;
  }

  Future<User?> getUserFromToken(String token) async {
    final url = HttpService.baseUrl + 'user/';
    Uri uri = Uri.parse(url);
    var response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      User user = User.fromJson(data);
      String? token = await FirebaseMessaging.instance.getToken();
      print('Firebase token:  ${token}');
      return user;
    } else {
      return null;
    }
  }

  Future<Driver?> getLogginDriver(int userId) async {
    final url = HttpService.baseUrl + 'driver/uid=${userId}';
    Uri uri = Uri.parse(url);
    var response = await http.get(
      uri,
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      Driver driver = Driver.fromJson(data);
      return driver;
    } else {
      // await FirebaseMessaging.instance.deleteToken();
      return null;
    }
  }

  Future<Driver?> getDriverInfo(int? id) async {
    if (id == null) return null;
    String? token = await storage.read(key: 'access_token');
    final url = HttpService.baseUrl + 'driver/id=${id}';
    Uri uri = Uri.parse(url);
    var response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      Driver driver = Driver.fromJson(data);
      return driver;
    } else {
      return null;
    }
  }

  static Future<Trip?>? addOrder(Trip trip) async {
    String? token = await storage.read(key: 'access_token');
    trip.order_time = DateTime.now();
    final url = HttpService.baseUrl + 'trip/';
    Uri uri = Uri.parse(url);
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: json.encode(trip.toJson()),
    );
    print(trip.toJson());
    final data = json.decode(response.body);
    if (data['data'] != null) return Trip.fromJson(data['data']);
    return null;
  }

  static Future<List<Trip>> getCurrentOrders(int uid) async {
    List<Trip> orders = [];
    // ing? token = await storage.read(key: 'access_token');
    final url = HttpService.baseUrl + 'trip/current/$uid';
    final uri = Uri.parse(url);
    var response = await http.get(uri);
    var data = response.body;
    if (response.statusCode == 200) {
      List jsons = json.decode(data) as List;
      orders = jsons.map((element) => Trip.fromJson(element)).toList();
    } else {
      final error = json.decode(data);
      print(error['message']);
    }
    return orders;
  }

  static Future<Trip?> getDriverCurrentTrip(int id) async {
    final url = HttpService.baseUrl + 'trip/driver_id=$id&&status=Processing';
    final uri = Uri.parse(url);
    var response = await http.get(uri);
    var data = json.decode(response.body);
    if (data['data'] != null) {
      // print(data['data']);
      return Trip.fromJson(data['data']);
    }
    return null;
  }

  static Future<List<Trip>> getValidOrders(String cabType) async {
    List<Trip> orders = [];
    final url = HttpService.baseUrl + 'trip/status=Waitting&&cab_type=$cabType';
    final uri = Uri.parse(url);
    var response = await http.get(uri);
    var data = response.body;
    if (response.statusCode == 200) {
      List jsons = json.decode(data) as List;
      orders = jsons.map((element) => Trip.fromJson(element)).toList();
    } else {
      final error = json.decode(data);
      print(error['message']);
    }
    return orders;
  }

  static Future<Map<String, dynamic>?> acceptOrder(
      Trip trip, Driver driver) async {
    String? token = await storage.read(key: 'access_token');
    final url = HttpService.baseUrl + 'trip/accept/${trip.id}';
    final uri = Uri.parse(url);
    var res = await http.put(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    var data = json.decode(res.body);
    print('Accept res: ${res.statusCode}');
    return data;
  }

  static endTrip(Trip trip) async {
    String? token = await storage.read(key: 'access_token');
    var res = await http.put(
      Uri.parse(HttpService.baseUrl + 'trip/end/${trip.id}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(trip.toJson()),
    );
    if (res.statusCode == 201) return json.decode(res.body)['message'];
    return 'error';
  }

  static sendNotification(NotificationModel notification) async {
    String? token = await storage.read(key: 'access_token');
    var notifyRes = await http.post(
      Uri.parse(HttpService.baseUrl + 'notification/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(notification.toJson()),
    );
    print(json.decode(notifyRes.body)['message']);
  }

  setUserOfToken(User user, int type) async {
    String retVal = 'success';
    String os = Platform.operatingSystem;
    String? token = await FirebaseMessaging.instance.getToken();
    final url = Uri.parse(HttpService.baseUrl + 'fcm/');
    var fcmDevice = FCMDevice(
      registration_id: token!,
      user: user.id,
      name: type == 1 ? 'User' : 'Driver',
      type: os,
    );
    var res = await http.post(url,
        body: json.encode(fcmDevice.toJson()),
        headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      retVal = json.decode(res.body)['message'];
    }
    return retVal;
  }

  deleteFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    final url = Uri.parse(HttpService.baseUrl + 'fcm/$token');
    await http.delete(url);
  }

  updateUser(Map<String, dynamic> user) async {
    String? token = await storage.read(key: 'access_token');
    final url = HttpService.baseUrl + 'user/${user['id']}';
    final uri = Uri.parse(url);
    var res = await http.put(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(user),
    );
    if (res.statusCode == 200) {
      return 'success';
    }
    // String message = json.decode(res.body)['message'];
    String message = 'error';
    print(message);
    return message;
  }

  static Future<Map<String, dynamic>?> getTrip(int? id) async {
    final url = HttpService.baseUrl + 'trip/$id';
    final uri = Uri.parse(url);
    var res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    return null;
  }

  static Future<List<Trip>?> getTrips(User user) async {
    List<Trip> trips = [];
    final url = HttpService.baseUrl + 'trip/all/${user.id}';
    final uri = Uri.parse(url);
    var res = await http.get(uri);
    if (res.statusCode == 200) {
      var data = json.decode(res.body) as List;
      trips = data
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();
      return trips;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo(int uid) async {
    final url = HttpService.baseUrl + 'user/$uid';
    final uri = Uri.parse(url);
    var res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else
      return null;
  }

  static Future<List<NotificationModel>> getNotification(
      int id, int userType) async {
    final url =
        HttpService.baseUrl + 'notification/id=$id&&user_type=$userType';
    final uri = Uri.parse(url);
    var res = await http.get(uri);
    if (res.statusCode == 200) {
      List datas = json.decode(res.body) as List;
      return datas.map((data) => NotificationModel.fromJson(data)).toList();
    } else {
      print(json.decode(res.body)['message']);
      return [];
    }
  }

  static setSeenNotification(NotificationModel notification) async {
    String? token = await storage.read(key: 'access_token');
    final url = HttpService.baseUrl + 'notification/${notification.id}';
    final uri = Uri.parse(url);
    print(notification.trip);
    await http.put(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(notification.toJson()),
    );
  }
}
