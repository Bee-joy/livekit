import 'package:dio/dio.dart';
import 'package:dipesh/Master/Master.dart';
import 'package:dipesh/Model/TokenModel.dart';
import 'package:dipesh/Model/UserModel.dart';

class ApiService {
  Map data = new Map();
  Dio dio = Dio();
  final String? baseurl = Master.endPoint;
  ApiService() {
    dio.options.headers['content-Type'] = 'application/json';
  }

  Future<User> getUser(String name) async {
    data['name'] = name;
    String url = Master.pwCommunity;
    try {
      Response responsePost = await dio.post(url + "/login", data: data);
      return User.fromJson(responsePost.data);
    } catch (e) {
      throw Exception('Failed to create user.');
    }
  }

  Future<Token> getToken(String userId, String roomName) async {
    String url = Master.pwVideoApi;
    dio.options.headers["userId"] = "${userId}";
    data['roomName'] = roomName;
    try {
      Response responsePost = await dio.post(url + "/token", data: data);
      return Token.fromJson(responsePost.data);
    } catch (e) {
      throw Exception('Failed to create user.');
    }
  }

  Future<void> updateMetadata(
      String userId, String roomId, String identifier, bool handRaise) async {
    var data = {
      'roomId': roomId,
      'identifier': identifier,
      'items': {"handRaise": handRaise},
    };

    String url = Master.pwVideoApi;
    dio.options.headers["userId"] = "${userId}";
    try {
      Response responsePost =
          await dio.post(url + "/update-metadata", data: data);
      print(responsePost);
    } catch (e) {
      throw Exception('Failed to create user.');
    }
  }

  Future<void> updatePermission(
      String userId, String roomId, String identifier) async {
    var data = {
      "roomId": roomId,
      "identifier": identifier,
      "userId": userId,
      "doPublish": true
    };

    String url = Master.pwVideoApi;
    dio.options.headers["userId"] = "${userId}";
    try {
      Response responsePost =
          await dio.post(url + "/update-permission", data: data);
      print(responsePost);
    } catch (e) {
      throw Exception('Failed to create user.');
    }
  }

  Future<void> kickOut(String userId, String roomId, String identifier) async {
    var data = {"roomId": roomId, "identifier": identifier};
    String url = Master.pwVideoApi;
    dio.options.headers["userId"] = "${userId}";
    try {
      Response responsePost = await dio.post(url + "/kickOut", data: data);
      print(responsePost);
    } catch (e) {
      throw Exception('Failed to create user.');
    }
  }
}
