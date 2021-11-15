import 'package:car_app/models/location.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trip.g.dart';

@JsonSerializable()
class Trip {
  int? id;
  int user;
  int? driver;
  Location start_location;
  Location end_location;
  DateTime? order_time;
  DateTime? start_time;
  DateTime? end_time;
  int? price;
  double? user_rating;
  String? user_review;
  String status;
  String cab_type;

  Trip({
    this.id,
    this.driver,
    this.order_time,
    this.start_time,
    this.end_time,
    this.price,
    this.user_rating,
    this.user_review,
    required this.user,
    required this.start_location,
    required this.end_location,
    required this.status,
    required this.cab_type,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);
}
