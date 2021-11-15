// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int?,
    address: json['address'] as String?,
    date_updated: json['date_updated'] == null
        ? null
        : DateTime.parse(json['date_updated'] as String),
    email: json['email'] as String?,
    data_joined: json['data_joined'] == null
        ? null
        : DateTime.parse(json['data_joined'] as String),
    avatar_url: json['avatar_url'] as String?,
    age: json['age'] as int,
    name: json['name'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    phone: json['phone'] as String,
    user_type: json['user_type'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'age': instance.age,
      'address': instance.address,
      'date_updated': instance.date_updated?.toIso8601String(),
      'email': instance.email,
      'name': instance.name,
      'username': instance.username,
      'password': instance.password,
      'phone': instance.phone,
      'data_joined': instance.data_joined?.toIso8601String(),
      'user_type': instance.user_type,
      'avatar_url': instance.avatar_url,
    };
