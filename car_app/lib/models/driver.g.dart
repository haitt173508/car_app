// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) {
  return Driver(
    id: json['id'] as int?,
    status: json['status'] as String,
    rating: (json['rating'] as num).toDouble(),
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    cab: Cab.fromJson(json['cab'] as Map<String, dynamic>),
    license_driver: json['license_driver'] as String,
  );
}

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'cab': instance.cab,
      'status': instance.status,
      'rating': instance.rating,
      'license_driver': instance.license_driver,
    };
