import 'dart:convert';
import 'package:collection/collection.dart';
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
  static ParticipantWidget widgetFor(
      ParticipantTrack participantTrack, List<ParticipantOption> list) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
          list,
          participantTrack.participant as LocalParticipant,
          participantTrack.videoTrack,
          participantTrack.isScreenShare);
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
          list,
          participantTrack.participant as RemoteParticipant,
          participantTrack.videoTrack,
          participantTrack.isScreenShare);
    }
    throw UnimplementedError('Unknown participant type');
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
  final LocalParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final List<ParticipantOption> participantList;
  LocalParticipantWidget(
    this.participantList,
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
                alignment: Alignment.bottomCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...extraWidgets(widget.isScreenShare),
                    ParticipantInfoWidget(
                      title: UserMetaData.fromJson(
                              jsonDecode(widget.participant.metadata!))
                          .name,
                      audioAvailable: firstAudioPublication?.muted == true &&
                          firstAudioPublication?.subscribed == true,
                      connectionQuality: widget.participant.connectionQuality,
                      isScreenShare: widget.isScreenShare,
                    ),
                  ],
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
                                if (metadata.roles!.contains('teacher') &&
                                    widget.participantList[index].name !=
                                        metadata.name)
                                  Popup(
                                    menuList: [
                                      PopupMenuItem(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: ListTile(
                                            horizontalTitleGap: 10,
                                            minLeadingWidth: 10,
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 40,
                                                minHeight: 40,
                                                maxWidth: 40,
                                                maxHeight: 40,
                                              ),
                                              child: Image.asset(
                                                  "assets/images/kick.png",
                                                  fit: BoxFit.cover),
                                            ),
                                            onTap: () => {
                                              widget.participantList
                                                  .remove(index),
                                              _kickOut(widget
                                                  .participantList[index]
                                                  .participant)
                                            },
                                            title: const Text(
                                              "Kick out",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )),
                                      PopupMenuItem(
                                          child: ListTile(
                                        horizontalTitleGap: 10,
                                        minVerticalPadding: 0.0,
                                        minLeadingWidth: 10,
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.logout),
                                        onTap: () => _updatePermission(widget
                                            .participantList[index]
                                            .participant),
                                        title: const Text(
                                          "Allow to talk",
                                          style: TextStyle(color: Colors.blue),
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

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTracks
          .where((element) => element.sid == widget.videoTrack?.sid)
          .firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
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
      itemBuilder: ((context) => menuList),
      icon: icon,
    );
  }
}
