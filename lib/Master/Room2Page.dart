import 'package:dipesh/ApiService/ApiService.dart';
import 'package:dipesh/Model/UserMetaData.dart';
import 'package:dipesh/Model/participantoptions.dart';
import 'package:dipesh/widgets/controls.dart';
import 'package:dipesh/widgets/participant.dart';
import 'package:dipesh/widgets/participant_info.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class Room2Page extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;
  final _messageBody = new TextEditingController();

  Room2Page(
    this.room,
    this.listener, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Room2PageState();
}

class _Room2PageState extends State<Room2Page> {
  ApiService apiService = new ApiService();
  //
  List<ParticipantTrack> participantTracks = [];
  List<ParticipantOption> participantsList = [];
  EventsListener<RoomEvent> get _listener => widget.listener;

  LocalParticipant? participent;
  // EventsListener<RoomEvent> get _parListener => widget.parListener;
  @override
  void initState() {
    super.initState();
    participent = widget.room.localParticipant;
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();
  }

  @override
  void dispose() {
    // always dispose listener
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      // await _parListener.dispose();
      await widget.room.dispose();
    })();
    super.dispose();
  }

  void _setUpListeners() => {
        _listener
          ..on<RoomDisconnectedEvent>((_) async {
            WidgetsBindingCompatible.instance
                ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
          })
          ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
          ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
          ..on<DataReceivedEvent>((event) {
            String decoded = 'Failed to decode';
            try {
              decoded = utf8.decode(event.data);
            } catch (_) {
              print('Failed to decode: $_');
            }
            // context.showDataReceivedDialog(decoded);
          })
        //   ,
        // _parListener
        //   ..on<ParticipantMetadataUpdatedEvent>(
        //       (participent) => updateParticipate())
      };

  void updateParticipate() {
    //update participante list here
  }

  void _kickOut(RemoteParticipant participant) async {
    UserMetaData metadata =
        UserMetaData.fromJson(jsonDecode(participant.metadata!));
    await apiService.kickOut(
        metadata.userId!, participant.room.name!, participant.identity);
  }

  void _updatePermission() async {
    UserMetaData metadata = UserMetaData.fromJson(
        jsonDecode(widget.room.localParticipant!.metadata!));
    await apiService.updatePermission(metadata.userId!, widget.room.name!,
        widget.room.localParticipant!.identity);
  }

  // void _askPublish() async {
  //   final result = await context.showPublishDialog();
  //   if (result != true) return;
  //   // video will fail when running in ios simulator
  //   try {
  //     await widget.room.localParticipant?.setCameraEnabled(true);
  //   } catch (error) {
  //     print('could not publish video: $error');
  //     await context.showErrorDialog(error);
  //   }
  //   try {
  //     await widget.room.localParticipant?.setMicrophoneEnabled(true);
  //   } catch (error) {
  //     print('could not publish audio: $error');
  //     await context.showErrorDialog(error);
  //   }
  // }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    if (participent?.metadata != null)
      print("METADATA" + participent!.metadata!);
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    for (var participant in widget.room.participants.values) {
      for (var t in participant.videoTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }
    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = widget.room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }
    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];

      widget.room.participants.values
          .map((participant) => addParticipant(participant));
      // UserMetaData metadata = UserMetaData.fromJson(
      //     jsonDecode(widget.room.localParticipant!.metadata!));
      // participantsList.add(ParticipantOption(
      //     name: metadata.name!, image: "", raiseHand: metadata.raiseHand));
    });
  }

  void addParticipant(Participant participant) {
    UserMetaData metadata =
        UserMetaData.fromJson(jsonDecode(participant.metadata!));

    participantsList.add(ParticipantOption(
        name: metadata.name!, image: "", raiseHand: metadata.raiseHand));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Expanded(
                child: participantTracks.isNotEmpty
                    ? ParticipantWidget.widgetFor(
                        participantTracks.first, participantsList)
                    : Container()),
            // SizedBox(
            //   height: 50,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: math.max(0, participantTracks.length - 1),
            //     itemBuilder: (BuildContext context, int index) => SizedBox(
            //       width: 100,
            //       height: 100,
            //       child:
            //           ParticipantWidget.widgetFor(participantTracks[index + 1]),
            //     ),
            //   ),
            // ),
            if (widget.room.localParticipant != null)
              Row(children: [
                ControlsWidget(widget.room, widget.room.localParticipant!),
              ]),
            // SizedBox(
            //     height: MediaQuery.of(context).size.height * .2,
            //     child: ListView.builder(
            //         itemCount: 150,
            //         itemBuilder: (BuildContext context, index) {
            //           return Text('index $index');
            //         })),

            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //   height: 70.0,
            //   color: Colors.white,
            //   child: Row(
            //     children: <Widget>[
            //       Expanded(
            //         child: TextField(
            //           controller: widget._messageBody,
            //           textCapitalization: TextCapitalization.sentences,
            //           onChanged: (value) {
            //             setState(() {});
            //           },
            //           decoration: const InputDecoration.collapsed(
            //             hintText: 'Send a message...',
            //           ),
            //         ),
            //       ),
            //       RawMaterialButton(
            //         onPressed: () {},
            //         elevation: 2.0,
            //         fillColor: const Color(0xFFd1c9f3),
            //         child: const Icon(
            //           Icons.send,
            //           size: 20.0,
            //           color: Colors.white,
            //         ),
            //         padding: const EdgeInsets.all(15.0),
            //         shape: const CircleBorder(),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      );
}
