// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return NotificationModel(
    id: json['id'] as int?,
    title: json['title'] as String?,
    body: json['body'] as String?,
    notice_time: json['notice_time'] == null
        ? null
        : DateTime.parse(json['notice_time'] as String),
    status: json['status'] as String?,
    receiver: json['receiver'] as int?,
    receiver_type: json['receiver_type'] as int?,
    category: json['category'] as int?,
    sender: json['sender'] as int?,
    trip: json['trip'] == null
        ? null
        : Trip.fromJson(json['trip'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'notice_time': instance.notice_time?.toIso8601String(),
      'status': instance.status,
      'receiver': instance.receiver,
      'receiver_type': instance.receiver_type,
      'category': instance.category,
      'sender': instance.sender,
      'trip': instance.trip,
    };
