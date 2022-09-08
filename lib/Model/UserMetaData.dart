import 'dart:convert';

UserMetaData metadataFromJson(String str) =>
    UserMetaData.fromJson(json.decode(str));

String metadataToJson(UserMetaData data) => json.encode(data.toJson());

class UserMetaData {
  UserMetaData(
      {this.profileImage, this.name, this.roles, this.userId, this.raiseHand});

  String? profileImage;
  String? name;
  List<String>? roles;
  String? userId;
  bool? raiseHand;

  factory UserMetaData.fromJson(Map<String, dynamic> json) => UserMetaData(
      profileImage: json["profileImage"],
      name: json["name"],
      roles: List<String>.from(json["roles"].map((x) => x)),
      userId: json["userId"],
      raiseHand: json["raiseHand"] ?? false);

  Map<String, dynamic> toJson() => {
        "profileImage": profileImage,
        "name": name,
        "roles": List<dynamic>.from(roles!.map((x) => x)),
        "userId": userId,
        "raiseHand": raiseHand
      };
}
