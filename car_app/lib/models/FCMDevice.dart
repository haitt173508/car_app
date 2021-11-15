import 'package:json_annotation/json_annotation.dart';

part 'FCMDevice.g.dart';

@JsonSerializable()
class FCMDevice {
  String registration_id;
  String? name;
  bool active;
  int? user;
  String? device_id;
  String? type;

  FCMDevice({
    required this.registration_id,
    this.active = true,
    this.name,
    this.user,
    this.device_id,
    this.type,
  });

  factory FCMDevice.fromJson(Map<String, dynamic> json) =>
      _$FCMDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$FCMDeviceToJson(this);
}
