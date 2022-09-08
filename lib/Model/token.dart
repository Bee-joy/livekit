import 'dart:convert';

Token tokenFromJson(String str) => Token.fromJson(json.decode(str));

String tokenToJson(Token data) => json.encode(data.toJson());

class Token {
  Token({
    this.statusCode,
    this.data,
  });

  int? statusCode;
  Data? data;

  factory Token.fromJson(Map<String, dynamic> json) => Token(
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
    this.token,
    this.server,
  });

  String? token;
  String? server;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        server: json["server"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "server": server,
      };
}
