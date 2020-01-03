import 'package:flutter/material.dart';

import 'body.dart';

class LogIn extends StatelessWidget {
  final auth;
  final onSignedIn;

  const LogIn({Key key, @required this.auth, @required this.onSignedIn}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Body(
        auth: auth,
        onSignedIn: onSignedIn,
      ),
    );
  }
}