import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/amount_card.dart';
import 'package:help_the_child_user/components/custom_center.dart';
import '../data_classes/user_data.dart';

class Body extends StatefulWidget {
  final totalDonation;

  const Body({Key key, @required this.totalDonation}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Widget _totalAmountCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).primaryColor,
      height: 160.0,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  "assets/images/donation.png",
                  height: 130,
                )),
          ),
          Positioned(
            right: 0,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                      widget.totalDonation != null
                          ? "₹${widget.totalDonation}"
                          : "₹0",
                      style: GoogleFonts.pacifico().copyWith(
                          fontSize: 48.0, height: 1, color: Colors.white)),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    "Total donate".toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                        color: Colors.white,
                        letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _donationGrid() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users/${userData.uid}/donations')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData) {
          if (snapshot.data.documents.length <= 0) {
            return CustomCenter(
              child: Text("You didn't donate yet."),
              extraValue: 160,
            );
          }
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CustomCenter(child: CircularProgressIndicator(), extraValue: 160,);

          default:
            return GridView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return AmountCard(
                    amount: snapshot.data.documents[index].data['amount'],
                    isDonation: true,
                  );
                });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _totalAmountCard(context),
        SizedBox(
          height: 4.0,
        ),
        _donationGrid(),
      ],
    );
  }
}
