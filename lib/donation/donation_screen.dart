import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';

import '../data_classes/user_data.dart';
import 'body.dart';


class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  double _totalDonation;

  void _fetchTotalDonation() {
    Firestore.instance.document('users/${userData.uid}').get().then((doc) {
      setState(() {
        _totalDonation = double.parse(doc.data['totalDonation'].toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTotalDonation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBody(
        scrollOffset: 160,
        appBarColor: Theme.of(context).primaryColor,
        appBarColorAfterScroll: Colors.white,
        appBarTitle: Text(
          "My Donations",
          style: GoogleFonts.patuaOne(

          ).copyWith(color: Colors.white)
        ),
        appBarTitleAfterScroll: Text(
          "₹$_totalDonation",
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
        body: Body(totalDonation: _totalDonation),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text(
          "DONATE NOW",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
