// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) {
  return Trip(
    id: json['id'] as int?,
    driver: json['driver'] as int?,
    order_time: json['order_time'] == null
        ? null
        : DateTime.parse(json['order_time'] as String),
    start_time: json['start_time'] == null
        ? null
        : DateTime.parse(json['start_time'] as String),
    end_time: json['end_time'] == null
        ? null
        : DateTime.parse(json['end_time'] as String),
    price: json['price'] as int?,
    user_rating: (json['user_rating'] as num?)?.toDouble(),
    user_review: json['user_review'] as String?,
    user: json['user'] as int,
    start_location:
        Location.fromJson(json['start_location'] as Map<String, dynamic>),
    end_location:
        Location.fromJson(json['end_location'] as Map<String, dynamic>),
    status: json['status'] as String,
    cab_type: json['cab_type'] as String,
  );
}

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'driver': instance.driver,
      'start_location': instance.start_location,
      'end_location': instance.end_location,
      'order_time': instance.order_time?.toIso8601String(),
      'start_time': instance.start_time?.toIso8601String(),
      'end_time': instance.end_time?.toIso8601String(),
      'price': instance.price,
      'user_rating': instance.user_rating,
      'user_review': instance.user_review,
      'status': instance.status,
      'cab_type': instance.cab_type,
    };
