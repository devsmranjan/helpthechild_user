import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmountCard extends StatelessWidget {
  final amount;
  final isDonation;

  const AmountCard({Key key, @required this.amount, this.isDonation = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              !isDonation
                  ? "assets/images/reward.png"
                  : "assets/images/donate-money.png",
              height: 72.0,
            ),
            SizedBox(
              height: 14.0,
            ),
            Text("₹$amount",
                style: GoogleFonts.pacifico().copyWith(
                    fontSize: 32.0,
                    height: 1,
                    color: Theme.of(context).accentColor))
          ],
        ),
      ),
    );
  }
}
