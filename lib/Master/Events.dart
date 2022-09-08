import 'package:flutter/cupertino.dart';

abstract class Events {}

class LoginEvent extends Events {
  BuildContext context;
  String username;
  LoginEvent(this.context, this.username);
}
