// To parse this JSON data, do
//
//     final participantOption = participantOptionFromJson(jsonString);

import 'dart:convert';

ParticipantOption participantOptionFromJson(String str) =>
    ParticipantOption.fromJson(json.decode(str));

String participantOptionToJson(ParticipantOption data) =>
    json.encode(data.toJson());

class ParticipantOption {
  ParticipantOption({
    this.name,
    this.image,
    this.raiseHand,
  });

  String? name;
  String? image;
  bool? raiseHand;

  factory ParticipantOption.fromJson(Map<String, dynamic> json) =>
      ParticipantOption(
        name: json["name"],
        image: json["image"],
        raiseHand: json["raiseHand"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "raiseHand": raiseHand,
      };
}
