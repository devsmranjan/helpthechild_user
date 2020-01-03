import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  final id;
  final title;
  final govt;
  final imgURL;
  final description;
  final url;

  const Body({
    Key key,
    @required this.id,
    @required this.title,
    @required this.govt,
    @required this.imgURL,
    @required this.description,
    @required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            url != null
                ? SizedBox(
                    height: 24.0,
                  )
                : Container(),
            url != null
                ? Container(
                    height: 200.0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: imgURL,
                          width: MediaQuery.of(context).size.width,
                        )),
                  )
                : Container,
            SizedBox(
              height: 24.0,
            ),
            Text(
              "Scheme",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF707070),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              title,
            ),
            SizedBox(
              height: 14.0,
            ),
            Text(
              "Goverment",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF707070),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              govt,
            ),
            SizedBox(
              height: 14.0,
            ),
            Text(
              "Description",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF707070),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              description,
            ),
            SizedBox(
              height: 48.0,
            ),
          ],
        ),
      ),
    );
  }
}
