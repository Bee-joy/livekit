import 'package:flutter/material.dart';

class Dialog {
  static showLoadingDialog(context, alertDialogTitle, alertDialogBody) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Please wait...',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ],
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            titleTextStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF-Pro-Display-Bold'),
            contentTextStyle: const TextStyle(color: Colors.blue),
            backgroundColor: Colors.blue,
          );
        });
  }

  static showLoginErrorDialog(context, alertDialogTitle, alertDialogBody) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.warning,
                  color: Color(0xFFffba00),
                ),
                Text(
                  alertDialogTitle,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ],
            ),
            content: Text(
              alertDialogBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            titleTextStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF-Pro-Display-Bold'),
            contentTextStyle: const TextStyle(color: Colors.blue),
            backgroundColor: Colors.blue,
          );
        });
  }
}
