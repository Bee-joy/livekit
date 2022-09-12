import 'package:dipesh/Master/Events.dart';
import 'package:dipesh/Master/LoginBloc.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final loginBloc = LoginBloc();
  bool isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFd1c9f3),
        body: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 100),
              child: Container(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width * .9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 15, left: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Username',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: StreamBuilder<Map>(
                                stream: loginBloc.loginStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!['status'] ==
                                          'processing') {
                                    isSuccess = true;
                                  } else {
                                    isSuccess = false;
                                  }
                                  return ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        loginBloc.eventSink.add(LoginEvent(
                                            context, _username.text));
                                      }
                                    },
                                    child: isSuccess
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Login'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(100, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // <-- Radius
                                      ),
                                    ),
                                  );
                                })),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
