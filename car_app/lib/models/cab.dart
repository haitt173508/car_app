import 'package:json_annotation/json_annotation.dart';

part 'cab.g.dart';

@JsonSerializable()
class Cab {
  String reg_no;
  String brand;
  String model;
  String cab_type;

  Cab({
    required this.reg_no,
    required this.brand,
    required this.model,
    required this.cab_type,
  });

  factory Cab.fromJson(Map<String, dynamic> json) => _$CabFromJson(json);
  Map<String, dynamic> toJson() => _$CabToJson(this);
}
