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
        padding: const EdgeInsets.only(top: 10, left: 8),
        child: InkWell(
          onTap: () => _showModalBottomSheet(
              context, participantsList, localParticipant),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(5))),
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
                  width: 10,
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
            child: Column(children: [
              Container(
                  height: 50,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10, top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Participants",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.of(context).pop()),
                        )
                      ],
                    ),
                  )),
              Divider(
                color: Colors.grey.shade400,
              ),
              Expanded(
                child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(0.0),
                        itemCount: participantsList.length,
                        itemBuilder: (BuildContext context, index) {
                          return ListTile(
                            title:
                                Text(participantsList[index].name.toString()),
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
                                    participantsList[index].name !=
                                        metadata.name)
                                  Popup(
                                    menuList: [
                                      PopupMenuItem(
                                          height: 0,
                                          padding: EdgeInsets.zero,
                                          child: InkWell(
                                            onTap: () => {
                                              participantsList.remove(index),
                                              _kickOut(participantsList[index]
                                                  .participant),
                                              Navigator.pop(context)
                                            },
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14, top: 8),
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 20,
                                                        minHeight: 20,
                                                        maxWidth: 20,
                                                        maxHeight: 20,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/images/kickout.png",
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14, top: 8),
                                                    child: Text(
                                                      "Kick out",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[800]),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                      PopupMenuItem(
                                          height: 0,
                                          padding: EdgeInsets.zero,
                                          child: InkWell(
                                            onTap: () => {
                                              _updatePermission(
                                                  participantsList[index]
                                                      .participant),
                                              Navigator.pop(context)
                                            },
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            top: 14,
                                                            bottom: 8),
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 20,
                                                        minHeight: 20,
                                                        maxWidth: 20,
                                                        maxHeight: 20,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/images/allowtotalk.png",
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            top: 14,
                                                            bottom: 8),
                                                    child: Text(
                                                      "Allow to talk",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .purple[800]),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                  ), // icon-2
                              ],
                            ),
                          );
                        })),
              )
            ]),
          );
        });
  }
}
