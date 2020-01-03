import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';

import '../data_classes/user_data.dart';
import 'body.dart';

class Profile extends StatefulWidget {
  final auth;

  const Profile({Key key, @required this.auth}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: CustomBody(
        appBarTitle: Text(""),
        appBarTitleAfterScroll: Text(
          userData.displayName,
          style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
        ),
        appBarLeading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft,
              color: Colors.black87, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Body(
          auth: widget.auth,
          scaffoldKey: _scaffoldKey
        ),
      ),
    );
  }
}
