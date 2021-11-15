// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cab _$CabFromJson(Map<String, dynamic> json) {
  return Cab(
    reg_no: json['reg_no'] as String,
    brand: json['brand'] as String,
    model: json['model'] as String,
    cab_type: json['cab_type'] as String,
  );
}

Map<String, dynamic> _$CabToJson(Cab instance) => <String, dynamic>{
      'reg_no': instance.reg_no,
      'brand': instance.brand,
      'model': instance.model,
      'cab_type': instance.cab_type,
    };
