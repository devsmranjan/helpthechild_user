import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import '../DCPU_details/dcpu_details_screen.dart';

class DCPOCard extends StatelessWidget {
  final id;
  final dcpoName;
  final dist;
  final contactNumber;

  const DCPOCard(
      {Key key,
      @required this.id,
      @required this.dcpoName,
      @required this.dist,
      @required this.contactNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DCPUDetails(
                  id: id,
                  dist: dist
                ), fullscreenDialog: true));
      },
      title: Text(dcpoName),
      subtitle: Text("DCPO, $dist"),
      trailing: IconButton(
        icon: Icon(
          FontAwesomeIcons.phoneAlt,
          size: 20.0,
        ),
        onPressed: () {
          launch("tel://$contactNumber");
        },
      ),
    );
  }
}
