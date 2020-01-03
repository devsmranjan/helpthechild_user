import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import '../data_classes/user_data.dart';
import 'body.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  _handelClear() {
    Firestore.instance
        .collection('users/${userData.uid}/notifications')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomBody(
          appBarTitle: Text(
            "Notifications",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87)
          ),
          appBarTitleAfterScroll: Text(
            "Notifications",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87)
          ),
          appBarLeading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft,
                color: Colors.black87, size: 20.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          appBarActions: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users/${userData.uid}/notifications')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }

                if (snapshot.hasData) {
                  if (snapshot.data.documents.length >= 1) {
                    return IconButton(
                      onPressed: _handelClear,
                      icon: Icon(FontAwesomeIcons.solidTrashAlt,
                          color: Colors.black87, size: 20.0),
                    );
                  }
                }

                return Container();
              },
            ),
          ],
          body: Body(),
        ));
  }
}
