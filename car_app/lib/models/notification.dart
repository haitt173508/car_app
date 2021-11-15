import 'package:car_app/apis/api.dart';
import 'package:car_app/models/trip.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  int? id;
  String? title;
  String? body;
  DateTime? notice_time;
  String? status;
  int? receiver;
  int? sender;
  int? receiver_type;
  int? category;
  Trip? trip;
  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.notice_time,
    this.status,
    this.receiver,
    this.sender,
    this.receiver_type,
    this.category,
    this.trip,
    this.data,
  });

  static fromRemoteMessage(RemoteMessage message) async {
    Trip? trip;
    int? tripId = message.data['trip'] == null
        ? null
        : int.tryParse(message.data['trip']);
    var res;
    await Api.getTrip(tripId).then((value) {
      if (value != null) trip = Trip.fromJson(value);
    });
    res = NotificationModel(
      id: message.data['id'] == null ? null : int.tryParse(message.data['id']),
      notice_time: message.data['notice_time'] == null
          ? null
          : DateTime.parse(message.data['notice_time']),
      body: message.notification?.body,
      title: message.notification?.title,
      status: message.data['status'],
      category: message.data['category'] == null
          ? null
          : int.tryParse(message.data['category']),
      data: message.data,
      receiver: message.data['receiver'] == null
          ? null
          : int.tryParse(message.data['receiver']),
      sender: message.data['sender'] == null
          ? null
          : int.tryParse(message.data['sender']),
      trip: trip,
    );

    print('Remote message data: ${message.data}');
    print(res.trip);
    return res;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
