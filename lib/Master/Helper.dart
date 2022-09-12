import 'dart:convert';

import 'package:dipesh/Model/participantoptions.dart';
import 'package:dipesh/widgets/participant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../ApiService/ApiService.dart';
import '../Model/UserMetaData.dart';

class Helper {
  static ApiService apiService = new ApiService();

  static getParticipantDetails(
      BuildContext context,
      List<ParticipantOption> participantsList,
      LocalParticipant? localParticipant) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 70, left: 5),
        child: InkWell(
          onTap: () => _showModalBottomSheet(
              context, participantsList, localParticipant),
          child: Container(
            color: Colors.black,
            width: 60,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(children: [
                const Icon(
                  Icons.people,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  participantsList.length.toString(),
                  style: const TextStyle(color: Colors.white),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  static void _kickOut(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.kickOut(
          metadata.userId!, participant.room.name!, participant.identity);
    }
  }

  static void _updatePermission(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.updatePermission(metadata.userId!,
          participant.room.name.toString(), participant.identity);
    }
  }

  static void _updateMetadata(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.updateMetadata(metadata.userId!,
          participant.room.name.toString(), participant.identity, true);
    }
  }

  static void _showModalBottomSheet(
      BuildContext context,
      List<ParticipantOption> participantsList,
      LocalParticipant? localParticipant) {
    UserMetaData metadata = new UserMetaData();
    if (localParticipant != null)
      metadata = UserMetaData.fromJson(jsonDecode(localParticipant.metadata!));
    showModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (BuildContext bc) {
          return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * .3,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0.0),
                  itemCount: participantsList.length,
                  itemBuilder: (BuildContext context, index) {
                    return ListTile(
                      title: Text(participantsList[index].name.toString()),
                      leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 21,
                          child: CircleAvatar(
                            backgroundColor: Color(0xffE5F5FB),
                            radius: 20,
                            backgroundImage: NetworkImage(
                                'https://picsum.photos/id/237/200/300'),
                          )),
                      trailing: Wrap(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: participantsList[index].raiseHand!
                                  ? const Icon(Icons.back_hand_outlined)
                                  : const Text("")),
                          if (metadata.roles!.contains('teacher') &&
                              participantsList[index].name != metadata.name)
                            Popup(
                              menuList: [
                                PopupMenuItem(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: ListTile(
                                      horizontalTitleGap: 10,
                                      minLeadingWidth: 10,
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                          maxWidth: 20,
                                          maxHeight: 20,
                                        ),
                                        child: Image.asset(
                                            "assets/images/kickout.png",
                                            height: 20,
                                            width: 20,
                                            fit: BoxFit.cover),
                                      ),
                                      onTap: () => {
                                        participantsList.remove(index),
                                        _kickOut(
                                            participantsList[index].participant)
                                      },
                                      title: const Text(
                                        "Kick out",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )),
                                PopupMenuItem(
                                    child: ListTile(
                                  horizontalTitleGap: 10,
                                  minLeadingWidth: 10,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                      maxWidth: 20,
                                      maxHeight: 20,
                                    ),
                                    child: Image.asset(
                                        "assets/images/allowtotalk.png",
                                        height: 20,
                                        width: 20,
                                        fit: BoxFit.cover),
                                  ),
                                  onTap: () => _updatePermission(
                                      participantsList[index].participant),
                                  title: Text(
                                    "Allow to talk",
                                    style: TextStyle(color: Colors.purple[400]),
                                  ),
                                )),
                              ],
                              icon: Icon(Icons.more_vert),
                            ), // icon-2
                        ],
                      ),
                    );
                  }));
        });
  }
}
