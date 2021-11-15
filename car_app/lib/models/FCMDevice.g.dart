// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FCMDevice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FCMDevice _$FCMDeviceFromJson(Map<String, dynamic> json) {
  return FCMDevice(
    registration_id: json['registration_id'] as String,
    active: json['active'] as bool,
    name: json['name'] as String?,
    user: json['user'] as int?,
    device_id: json['device_id'] as String?,
    type: json['type'] as String?,
  );
}

Map<String, dynamic> _$FCMDeviceToJson(FCMDevice instance) => <String, dynamic>{
      'registration_id': instance.registration_id,
      'name': instance.name,
      'active': instance.active,
      'user': instance.user,
      'device_id': instance.device_id,
      'type': instance.type,
    };
