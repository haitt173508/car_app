// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoCode _$GeoCodeFromJson(Map<String, dynamic> json) {
  return GeoCode(
    formatted_address: json['formatted_address'] as String,
    geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GeoCodeToJson(GeoCode instance) => <String, dynamic>{
      'formatted_address': instance.formatted_address,
      'geometry': instance.geometry,
    };
