import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import '../data_classes/user_data.dart';

import 'body.dart';

class Rewards extends StatefulWidget {
  @override
  _RewardsState createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  double _totalRewards;

  void _fetchTotalRewards() {
    Firestore.instance.document('users/${userData.uid}').get().then((doc) {
      setState(() {
        _totalRewards = double.parse(doc.data['totalRewards'].toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTotalRewards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBody(
        scrollOffset: 160,
        appBarColor: Theme.of(context).primaryColor,
        appBarColorAfterScroll: Colors.white,
        appBarTitle: Text("My Rewards",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.white)),
        appBarTitleAfterScroll: Text(
          "₹$_totalRewards",
          style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
        ),
        appBarLeading: IconButton(
          icon:
              Icon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        appBarLeadingAfterScroll: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft,
              color: Colors.black87, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Body(totalRewards: _totalRewards),
      ),
    );
  }
}
