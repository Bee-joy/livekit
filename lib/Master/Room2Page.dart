import 'package:dipesh/ApiService/ApiService.dart';
import 'package:dipesh/Master/Helper.dart';
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
            setParticipants();
          })
          ..on<RoomReconnectedEvent>((_) => setParticipants())
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
          ..on<ParticipantMetadataUpdatedEvent>(
              (participent) => updateParticipate(participent.participant))
      };

  void updateParticipate(Participant? newParticipent) {
    if (newParticipent != null) {
      if (newParticipent.metadata != null) {
        UserMetaData metadata = UserMetaData.fromJson(
            jsonDecode(newParticipent.metadata.toString()));
        for (int i = 0; i < participantsList.length; i++) {
          if (participantsList[i].name == metadata.name) {
            participantsList[i].raiseHand = metadata.handRaise;
            setParticipants();
          }
        }
      }
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
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
      setParticipants();
    });
  }

  void setParticipants() {
    participantsList.clear();
    Iterable<RemoteParticipant> remoteparticipants =
        widget.room.participants.values;
    for (int i = 0; i < remoteparticipants.length; i++) {
      addParticipant(remoteparticipants.elementAt(i));
    }

    if (widget.room.localParticipant != null) {
      UserMetaData metadata = UserMetaData.fromJson(
          jsonDecode(widget.room.localParticipant!.metadata!));

      if (!participantsList
          .map((item) => item.identity)
          .contains(widget.room.localParticipant!.identity)) {
        if (metadata.name != null) {
          participantsList.add(ParticipantOption(
              name: metadata.name!,
              image: "",
              identity: widget.room.localParticipant!.identity,
              raiseHand: metadata.handRaise,
              roles: (metadata.roles != null && metadata.roles?.length == 0)
                  ? "teacher"
                  : metadata.roles![0].toString(),
              participant: widget.room.localParticipant));
        }
      }
    }
  }

  void addParticipant(Participant participant) {
    UserMetaData metadata =
        UserMetaData.fromJson(jsonDecode(participant.metadata!));
    if (!participantsList.map((item) => item.name).contains(metadata.name)) {
      participantsList.add(ParticipantOption(
          name: metadata.name,
          image: "",
          identity: participant.identity,
          raiseHand: metadata.handRaise,
          roles: metadata.roles?.length == 0
              ? "teacher"
              : metadata.roles![0].toString(),
          participant: participant));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Expanded(
                child: participantTracks.isNotEmpty
                    ? ParticipantWidget.widgetFor(
                        participantTracks.first, participantsList)
                    : Container(
                        color: Colors.grey,
                        child: Helper.getParticipantDetails(context,
                            participantsList, widget.room.localParticipant),
                      )),
            // SizedBox(
            //   height: 100,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: math.max(0, participantTracks.length - 1),
            //     itemBuilder: (BuildContext context, int index) => SizedBox(
            //       width: 100,
            //       height: 100,
            //       child: ParticipantWidget.widgetFor(
            //           participantTracks[index + 1], participantsList),
            //     ),
            //   ),
            // ),
            if (widget.room.localParticipant != null)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ControlsWidget(widget.room, widget.room.localParticipant!),
              ]),
          ],
        ),
      );
}
