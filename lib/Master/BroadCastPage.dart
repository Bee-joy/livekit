import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadCastPage extends StatefulWidget {
  String channelName;
  bool isBroadcaster;
  String appId = "com.example.dipesh";
  BroadCastPage(
      {Key? key, required this.channelName, required this.isBroadcaster})
      : super(key: key);

  @override
  State<BroadCastPage> createState() => _BroadCastPageState();
}

class _BroadCastPageState extends State<BroadCastPage> {
  final _users = <int>[];
  bool muted = false;

  @override
  void dispose() {
    _users.clear();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initalizeAgora();
  }

  Future<void> initalizeAgora() async {
    await _initAgoraRtcEngine();
  }

  Future<void> _initAgoraRtcEngine() async {
    // _engine = await RtcEngine.create(widget.appId);
    // await _engine.enableVideo();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // if (widget.isBroadcaster) {
    //   await _engine.setClientRole(ClientRole.Broadcaster);
    // } else {
    //   await _engine.setClientRole(ClientRole.Audience);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Stack(
        children: [
          _broadcastView(),
          _toolbar(),
        ],
      ),
      Expanded(
        flex: 1,
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(height: 100, child: Text("Item 1")),
                Container(height: 100, child: Text("Item 2")),
                Container(height: 100, child: Text("Item 3")),
                Container(height: 100, child: Text("Item 4")),
                Container(height: 100, child: Text("Item 5")),
                Container(height: 100, child: Text("Item 6")),
                Container(height: 100, child: Text("Item 7")),
                Container(height: 100, child: Text("Item 8")),
                Container(height: 100, child: Text("Item 9")),
                Container(height: 100, child: Text("Item 10")),
              ],
            ),
          ),
        ),
      )
    ]));
  }

  Widget _toolbar() {
    return widget.isBroadcaster
        ? Container(
            height: MediaQuery.of(context).size.height * 0.70,
            alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(color: Colors.grey),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                child: const Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
            ]),
          )
        : const SizedBox();
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    return list;
  }

  Widget message() {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: const Icon(Icons.list),
              trailing: const Text(
                "GFG",
                style: TextStyle(color: Colors.green, fontSize: 15),
              ),
              title: Text("List item $index"));
        });
  }

  Widget _expandedVideoView(List<Widget> views) {
    final wrappedViews = views
        .map<Widget>((view) => Expanded(
                child: Container(
              child: view,
            )))
        .toList();
    return Expanded(child: Row(children: wrappedViews));
  }

  Widget _broadcastView() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          child: Column(children: [
            _expandedVideoView([views[0]])
          ]),
        );
      case 2:
        return Container(
          child: Column(children: [
            _expandedVideoView([views[0]]),
            _expandedVideoView([views[1]])
          ]),
        );
      case 3:
        return Container(
          child: Column(children: [
            _expandedVideoView(views.sublist(0, 2)),
            _expandedVideoView(views)
          ]),
        );
    }
    return Container();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
  }

  void _onSwitchCamera() {}
}
