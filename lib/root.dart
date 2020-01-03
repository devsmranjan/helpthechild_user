import 'package:flutter/material.dart';
import 'auth.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';

enum AuthStatus { notSignedIn, signedIn }

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  const RootPage({@required this.auth});

  @override
  _RootPageState createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  Map<String, dynamic> _currentUser;
  String uid;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkCurrentUser() async {
    try {
      _currentUser = await widget.auth.currentUser();
      setState(() {
        if (_currentUser != null) {
          _authStatus = AuthStatus.signedIn;
        } else {
          _authStatus = AuthStatus.notSignedIn;
        }
      });
      print("CURRENT USER ::::  $_currentUser");
    } catch (e) {
      print("CUREENT USER :::: NUll");
    }
  }

  void onSignedIn() async {
    setState(() {
        _authStatus = AuthStatus.signedIn;
    });
  }

  void onSignedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authStatus == AuthStatus.notSignedIn) {
      return LogIn(
        auth: widget.auth,
        onSignedIn: onSignedIn,
      );
    }
    return Home(
      auth: widget.auth,
      onSignedOut: onSignedOut,
    );

  }
}