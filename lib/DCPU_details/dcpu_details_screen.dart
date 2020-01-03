import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import 'body.dart';

class DCPUDetails extends StatefulWidget {
  final id;
  final dist;

  const DCPUDetails({Key key, @required this.id, @required this.dist})
      : super(key: key);

  @override
  _DCPUDetailsState createState() => _DCPUDetailsState();
}

class _DCPUDetailsState extends State<DCPUDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomBody(
          appBarTitle: Text(""),
          appBarTitleAfterScroll: Text(
            widget.dist,
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
          ),
          appBarLeading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:
                Icon(FontAwesomeIcons.times, color: Colors.black87, size: 20.0),
          ),
          body: Body(id: widget.id),
        ));
  }
}
