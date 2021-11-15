// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceDetail _$PlaceDetailFromJson(Map<String, dynamic> json) {
  return PlaceDetail(
    geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
    vicinity: json['vicinity'] as String?,
    name: json['name'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$PlaceDetailToJson(PlaceDetail instance) =>
    <String, dynamic>{
      'geometry': instance.geometry,
      'name': instance.name,
      'vicinity': instance.vicinity,
      'url': instance.url,
    };
