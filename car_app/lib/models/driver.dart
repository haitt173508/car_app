import 'package:car_app/models/cab.dart';
import 'package:car_app/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver.g.dart';

@JsonSerializable()
class Driver {
  int? id;
  User user;
  Cab cab;
  String status;
  double rating;
  String license_driver;

  Driver({
    this.id,
    this.status = 'Offline',
    this.rating = 0.0,
    required this.user,
    required this.cab,
    required this.license_driver,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  // @override
  // String toString() {
  //   String retVal = '';
  //   return retVal;
  // }
}
