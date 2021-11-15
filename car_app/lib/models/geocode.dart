import 'package:car_app/models/geometry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geocode.g.dart';

@JsonSerializable()
class GeoCode {
  String formatted_address;
  Geometry geometry;

  GeoCode({
    required this.formatted_address,
    required this.geometry,
  });

  factory GeoCode.fromJson(Map<String, dynamic> json) =>
      _$GeoCodeFromJson(json);
  Map<String, dynamic> toJson() => _$GeoCodeToJson(this);
}
