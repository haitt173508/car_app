import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  int age;
  String? address;
  DateTime? date_updated;
  String? email;
  String name;
  String username;
  String password;
  String phone;
  DateTime? data_joined;
  int user_type;
  String? avatar_url;

  User({
    this.id,
    this.address,
    this.date_updated,
    this.email,
    this.data_joined,
    this.avatar_url,
    required this.age,
    required this.name,
    required this.username,
    required this.password,
    required this.phone,
    required this.user_type,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'username: ${this.username},\npassword: ${this.password}';
    // return 'address: ${this.address}\nemail: ${this.email}\nname: ${this.name}\nusername: ${this.username}\nphone: ${this.phone}\njoined date: ${this.joined_date}';
  }
}
