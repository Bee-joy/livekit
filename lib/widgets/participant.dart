import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dipesh/Enums/Enum.dart';
import 'package:dipesh/Model/UserMetaData.dart';
import 'package:dipesh/Model/participantoptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../ApiService/ApiService.dart';
import 'no_video.dart';
import 'participant_info.dart';

abstract class ParticipantWidget extends StatefulWidget {
  // Convenience method to return relevant widget for participant
  static ParticipantWidget widgetFor(List<ParticipantTrack> participantTracks,
      ParticipantTrack participantTrack, List<ParticipantOption> list) {
    return LocalParticipantWidget(
        list,
        participantTracks,
        participantTrack.participant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare);
  }

  // Must be implemented by child class
  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
  abstract final bool isScreenShare;
  abstract final List<ParticipantOption> participantList;
  final VideoQuality quality;
  ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    Key? key,
  }) : super(key: key);
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final Participant participant;
  @override
  final VideoTrack? videoTrack;

  @override
  final List<ParticipantTrack>? participantTracks;

  @override
  final bool isScreenShare;
  @override
  final List<ParticipantOption> participantList;
  LocalParticipantWidget(
    this.participantList,
    this.participantTracks,
    this.participant,
    this.videoTrack,
    this.isScreenShare, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final List<ParticipantOption> participantList;

  RemoteParticipantWidget(
    this.participantList,
    this.participant,
    this.videoTrack,
    this.isScreenShare, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget>
    extends State<T> {
  //
  bool _visible = true;
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;
  VideoTrack? get activeSecondaryVideoTrack;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  // Notify Flutter that UI re-build is required, but we don't set anything here
  // since the updated values are computed properties.
  void _onParticipantChanged() => setState(() {});

  // Widgets to show above the info bar
  List<Widget> extraWidgets(bool isScreenShare) => [];
  ApiService apiService = ApiService();

  void _kickOut(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.kickOut(
          metadata.userId!, participant.room.name!, participant.identity);
    }
  }

  void _updatePermission(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.updatePermission(metadata.userId!,
          participant.room.name.toString(), participant.identity);
    }
  }

  void _updateMetadata(Participant? participant) async {
    if (participant != null) {
      UserMetaData metadata =
          UserMetaData.fromJson(jsonDecode(participant.metadata!));
      await apiService.updateMetadata(metadata.userId!,
          participant.room.name.toString(), participant.identity, true);
    }
  }

  @override
  Widget build(BuildContext ctx) => Padding(
        padding:
            const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          foregroundDecoration: BoxDecoration(
            border: widget.participant.isSpeaking && !widget.isScreenShare
                ? Border.all(
                    width: 5,
                    color: Colors.red,
                  )
                : null,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Theme.of(ctx).cardColor,
          ),
          child: Stack(
            children: [
              // Video
              InkWell(
                onTap: () => setState(() => _visible = !_visible),
                child: (activeVideoTrack != null && activeVideoTrack!.isActive)
                    ? VideoTrackRenderer(
                        activeVideoTrack!,
                        fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const NoVideoWidget(),
              ),

              Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      height: 120,
                      width: 100,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 5),
                          child: (activeSecondaryVideoTrack != null &&
                                  activeSecondaryVideoTrack!.isActive)
                              ? VideoTrackRenderer(
                                  activeSecondaryVideoTrack!,
                                  fit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                )
                              : const NoVideoWidget()))),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 5),
                  child: InkWell(
                    onTap: () => _showModalBottomSheet(context),
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
                            widget.participantList.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          )
                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom bar
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        width: 130,
                        height: 30,
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              UserMetaData.fromJson(
                                      jsonDecode(widget.participant.metadata!))
                                  .name
                                  .toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          )
                        ]))
                  ]),
                ),
              ),
            ],
          ),
        ),
      );

  void _showModalBottomSheet(BuildContext context) {
    UserMetaData metadata =
        UserMetaData.fromJson(jsonDecode(widget.participant.metadata!));
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
                    padding:
                        const EdgeInsets.only(left: 20, right: 10, top: 10),
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
                        itemCount: widget.participantList.length,
                        itemBuilder: (BuildContext context, index) {
                          return ListTile(
                            title: Text(
                                widget.participantList[index].name.toString()),
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
                                    child: widget
                                            .participantList[index].raiseHand!
                                        ? const Icon(Icons.back_hand_outlined)
                                        : const Text("")),
                                if (metadata.roles!.contains("teacher") &&
                                    widget.participantList[index].name !=
                                        metadata.name)
                                  Popup(
                                    menuList: [
                                      PopupMenuItem(
                                          height: 0,
                                          padding: EdgeInsets.zero,
                                          child: InkWell(
                                            onTap: () => {
                                              _kickOut(widget
                                                  .participantList[index]
                                                  .participant)
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
                                            onTap: () => _updatePermission(
                                                widget.participantList[index]
                                                    .participant),
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
                                  ),

                                /// icon-2
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

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  VideoTrack? getSecondaryVideoTrack(List<ParticipantTrack>? videoTracks) {
    VideoTrack? track;
    if (!(videoTracks == null || videoTracks.isEmpty)) {
      for (int i = videoTracks.length - 1; i >= 0; i--) {
        ParticipantTrack currentTrack = videoTracks[i];
        UserMetaData metadata = UserMetaData.fromJson(
            jsonDecode(currentTrack.participant.metadata!));
        if (!metadata.roles!.contains("teacher") &&
            currentTrack.participant.isCameraEnabled()) {
          track = currentTrack.videoTrack;
          break;
        }
      }
    }
    return track;
  }

  VideoTrack? getPrimaryVideoTrack(List<ParticipantTrack>? videoTracks) {
    VideoTrack? track;
    if (!(videoTracks == null || videoTracks.isEmpty)) {
      for (int i = 0; i < videoTracks.length; i++) {
        ParticipantTrack currentTrack = videoTracks[i];
        UserMetaData metadata = UserMetaData.fromJson(
            jsonDecode(currentTrack.participant.metadata!));
        if (metadata.roles!.contains("teacher") &&
            currentTrack.participant.isCameraEnabled()) {
          return currentTrack.videoTrack;
        }
      }
    }
    return track;
  }

  @override
  TrackPublication<Track>? get videoPublication =>
      widget.participant.videoTracks
          .where((element) => element.sid == widget.videoTrack?.sid)
          .firstOrNull;

  @override
  TrackPublication<Track>? get firstAudioPublication =>
      widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack =>
      getPrimaryVideoTrack(widget.participantTracks);

  @override
  VideoTrack? get activeSecondaryVideoTrack =>
      getSecondaryVideoTrack(widget.participantTracks);
}

class _RemoteParticipantWidgetState
    extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTracks
          .where((element) => element.sid == widget.videoTrack?.sid)
          .firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;

  @override
  List<Widget> extraWidgets(bool isScreenShare) => [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Menu for RemoteTrackPublication<RemoteVideoTrack>
            if (videoPublication != null)
              RemoteTrackPublicationMenuWidget(
                pub: videoPublication!,
                icon: isScreenShare ? Icons.monitor : Icons.abc,
              ),
            // Menu for RemoteTrackPublication<RemoteAudioTrack>
            if (firstAudioPublication != null && !isScreenShare)
              RemoteTrackPublicationMenuWidget(
                pub: firstAudioPublication!,
                icon: Icons.volume_down,
              ),
          ],
        ),
      ];

  @override
  VideoTrack? get activeSecondaryVideoTrack => null;
}

class RemoteTrackPublicationMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackPublicationMenuWidget({
    required this.pub,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: PopupMenuButton<Function>(
          tooltip: 'Subscribe menu',
          icon: Icon(icon,
              color: {
                TrackSubscriptionState.notAllowed: Colors.red,
                TrackSubscriptionState.unsubscribed: Colors.grey,
                TrackSubscriptionState.subscribed: Colors.green,
              }[pub.subscriptionState]),
          onSelected: (value) => value(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
            // Subscribe/Unsubscribe
            if (pub.subscribed == false)
              PopupMenuItem(
                child: const Text('Subscribe'),
                value: () => pub.subscribe(),
              )
            else if (pub.subscribed == true)
              PopupMenuItem(
                child: const Text('Un-subscribe'),
                value: () => pub.unsubscribe(),
              ),
          ],
        ),
      );
}

class Popup extends StatelessWidget {
  final List<PopupMenuEntry> menuList;
  final Widget? icon;
  const Popup({Key? key, required this.menuList, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      itemBuilder: ((context) => menuList),
      icon: icon,
    );
  }
}
