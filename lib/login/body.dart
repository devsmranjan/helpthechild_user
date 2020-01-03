import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Body extends StatefulWidget {
  final auth;
  final onSignedIn;

  const Body({Key key, @required this.auth, @required this.onSignedIn})
      : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Map<String, dynamic> _currentUser = {};
  Map<String, dynamic> _profile = {};
  String _uid;
  String _email;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _pushToken;

  Future _uploadProfileData() async {
    _currentUser = await widget.auth.currentUser();

    _uid = _currentUser['uid'];
    _email = _currentUser['email'];

    await _firebaseMessaging.getToken().then((token) {
      _pushToken = token;
    });

    DocumentReference _docRefForUser =
        Firestore.instance.document('users/$_uid');

    if (_uid != null) {
      QuerySnapshot snapshot = await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: _uid)
          .limit(1)
          .getDocuments();

      if (snapshot.documents.length != 1) {
        _profile = <String, dynamic>{
          'uid': _uid,
          'name': _currentUser['displayName'],
          'photoURL': _currentUser['photoUrl'],
          'email': _email,
          'phone': "",
          'address': "",
          'pushToken': _pushToken,
          'totalRewards': 0,
          'totalDonation': 0
        };

        _docRefForUser.setData(_profile).whenComplete(() {
          print("Successfully pused to $_uid");
          Navigator.pop(context);
          widget.onSignedIn();
        });
      } else {
        _docRefForUser.updateData({"pushToken": _pushToken}).whenComplete(() {
          print("Updated Successfuly");
          Navigator.pop(context);
          widget.onSignedIn();
        });
      }
    }
  }

  Widget _loginButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: EdgeInsets.all(18.0),
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.google,
                size: 18.0,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Sign in with Google".toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        letterSpacing: 0.8),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () async {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              });
          await widget.auth.googleSignIn();
          try {
            if (await widget.auth.currentUser() != null) {
              _uploadProfileData();
            }
          } catch (e) {
            print("Error in sign in.");
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Opacity(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
            opacity: 0.5,
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                _loginButton(context)
              ],
            ),
          ),
        ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Let's take a move for a better India.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 14.0,
              ),
              Container(
                height: 8.0,
                width: 36.0,
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
          top: 72.0,
          left: 18.0,
          right: 18.0,
        ),
      ],
    );
  }
}
