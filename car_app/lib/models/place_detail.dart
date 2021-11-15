import 'package:car_app/models/geometry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place_detail.g.dart';

@JsonSerializable()
class PlaceDetail {
  final Geometry geometry;
  final String? name;
  final String? vicinity;
  final String? url;

  PlaceDetail({
    required this.geometry,
    this.vicinity,
    this.name,
    this.url,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceDetailToJson(this);
}
