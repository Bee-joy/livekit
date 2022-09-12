import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dipesh/ApiService/ApiService.dart';
import 'package:dipesh/Master/Dialog.dart';
import 'package:dipesh/Master/Events.dart';
import 'package:dipesh/Master/Master.dart';
import 'package:dipesh/Master/Room2Page.dart';
import 'package:dipesh/Model/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class LoginBloc {
  //To control all the events
  final _eventController = StreamController<Events>();
  Sink<Events> get eventSink => _eventController.sink;
  final _mapStateController = StreamController<Map>.broadcast();

  Sink<Map> get loginSink => _mapStateController.sink;
  Stream<Map> get loginStream => _mapStateController.stream;
  LoginBloc() {
    _eventController.stream.listen(_actions);
  }

  ApiService apiService = new ApiService();

  Future _actions(Events event) async {
    if (event is LoginEvent) {
      loginSink.add({
        'status': 'processing',
      });
      final room = Room();
      final listener = room.createListener();
      final parListener = room.participants.forEach((key, value) {
        value.createListener();
      });
      User user = await apiService.getUser(event.username);
      if (user.statusCode != 200 && user.statusCode != 200) {
        loginSink.add({'status': 'failed'});
      }
      try {
        await apiService
            .getToken(user.data!.userId!, "6315a1993fbbdd1bcffasb741")
            .then((value) => {
                  room
                      .connect(
                          'ws://ec2-65-0-31-130.ap-south-1.compute.amazonaws.com:7880',
                          value.data!.token!,
                          roomOptions: const RoomOptions(
                            defaultScreenShareCaptureOptions:
                                ScreenShareCaptureOptions(
                                    useiOSBroadcastExtension: true),
                          ))
                      .onError((error, stackTrace) =>
                          loginSink.add({'status': 'failed'})),
                  Navigator.push<void>(
                      event.context,
                      MaterialPageRoute(
                          builder: (_) => Room2Page(room, listener)))
                });
      } catch (e) {
        loginSink.add({'status': 'failed'});
      }
    }
  }
}
