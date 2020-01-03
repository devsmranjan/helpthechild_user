import 'package:flutter/material.dart';
import '../govt_scheme_details/govt_scheme_details_screen.dart';

class SchemeCard extends StatelessWidget {
  final id;
  final schemeName;
  final govt;

  const SchemeCard({Key key, @required this.id, @required this.schemeName, @required this.govt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GovtSchemeDetails(
                          id: id,
                        )));
          },
          title: Text(schemeName),
          subtitle: Text(govt),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}
