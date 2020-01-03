import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';

import 'body.dart';


class GovtSchemes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBody(
        appBarTitle: Text(
          "Govt Schemes",
          style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
        ),
        appBarLeading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft,
              color: Colors.black87, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Body(),
      ),
    );
  }
}
