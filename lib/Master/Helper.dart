import 'package:dipesh/Model/participantoptions.dart';
import 'package:dipesh/widgets/participant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Helper {
  static getParticipantDetails(
      BuildContext context, List<ParticipantOption> participantsList) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 70, left: 5),
        child: InkWell(
          onTap: () => _showModalBottomSheet(context, participantsList),
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

  static void _showModalBottomSheet(
      BuildContext context, List<ParticipantOption> participantsList) {
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
                              child: participantsList[index].roles == 'student'
                                  ? const Icon(Icons.back_hand_outlined)
                                  : const Text("")),
                          participantsList[index].roles == 'student'
                              ? const Popup(
                                  menuList: [
                                    PopupMenuItem(
                                        child: ListTile(
                                      horizontalTitleGap: 10,
                                      minVerticalPadding: 0.0,
                                      minLeadingWidth: 10,
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(Icons.logout),
                                      title: Text(
                                        "Allow to talk",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    )),
                                  ],
                                  icon: Icon(Icons.more_vert),
                                )
                              : const Popup(
                                  menuList: [
                                    PopupMenuItem(
                                        padding: EdgeInsets.only(left: 16),
                                        child: ListTile(
                                          horizontalTitleGap: 10,
                                          minLeadingWidth: 10,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(Icons.event_busy_sharp),
                                          title: Text(
                                            "Kick out",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )),
                                    PopupMenuItem(
                                        child: ListTile(
                                      horizontalTitleGap: 10,
                                      minVerticalPadding: 0.0,
                                      minLeadingWidth: 10,
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(Icons.logout),
                                      title: Text(
                                        "Allow to talk",
                                        style: TextStyle(color: Colors.blue),
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
