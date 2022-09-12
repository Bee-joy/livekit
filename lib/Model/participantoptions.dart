// To parse this JSON data, do
//
//     final participantOption = participantOptionFromJson(jsonString);

import 'dart:convert';

import 'package:livekit_client/livekit_client.dart';

ParticipantOption participantOptionFromJson(String str) =>
    ParticipantOption.fromJson(json.decode(str));

String participantOptionToJson(ParticipantOption data) =>
    json.encode(data.toJson());

class ParticipantOption {
  ParticipantOption(
      {this.name,
      this.image,
      this.raiseHand,
      this.roles,
      this.identity,
      this.participant});

  String? name;
  String? image;
  bool? raiseHand;
  String? roles;
  String? identity;
  Participant? participant;

  factory ParticipantOption.fromJson(Map<String, dynamic> json) =>
      ParticipantOption(
        name: json["name"],
        image: json["image"],
        identity: json["identity"],
        raiseHand: json["raiseHand"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "raiseHand": raiseHand,
        "identity": identity
      };
}
