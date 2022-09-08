// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.statusCode,
    this.data,
  });

  int? statusCode;
  Data? data;

  factory User.fromJson(Map<String, dynamic> json) => User(
        statusCode: json["statusCode"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.userId,
    this.roles,
    this.name,
  });

  String? userId;
  List<String>? roles;
  String? name;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        roles: List<String>.from(json["roles"].map((x) => x)),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "roles": List<dynamic>.from(roles!.map((x) => x)),
        "name": name,
      };
}
