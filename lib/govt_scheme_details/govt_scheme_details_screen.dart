import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import 'body.dart';


class GovtSchemeDetails extends StatefulWidget {
  final id;

  const GovtSchemeDetails({Key key, @required this.id}) : super(key: key);

  @override
  _GovtSchemeDetailsState createState() => _GovtSchemeDetailsState();
}

class _GovtSchemeDetailsState extends State<GovtSchemeDetails> {
  StreamSubscription<List> _dataSub;
  String _title;
  String _govt;
  String _imgURL;
  String _description;
  String _url;
  bool _allLoaded = false;

  _getGovtScheme() {
    Firestore.instance.document('govtSchemes/${widget.id}').get().then((doc) {
      setState(() {
        _title = doc.data['title'];
        _govt = doc.data['govt'];
        _imgURL = doc.data['imgURL'];
        _description = doc.data['description'];
        _url = doc.data['url'];
        _allLoaded = true;
      });
    });
  }

  Future<List> _handelImgDownload() async {
    print("Start share.....");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              child: Container(
                padding: EdgeInsets.only(top: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(),
                    SizedBox(
                      height: 18.0,
                    ),
                    FlatButton(
                      onPressed: _cancelSharing,
                      child: Text("CANCEL"),
                    )
                  ],
                ),
              ),
            ));
    var request = await HttpClient().getUrl(Uri.parse(_imgURL));
    print("Request done.....");
    var response = await request.close();
    print("Response done.....");
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    print("bytes done.....");

    return bytes;
  }

  void _handelShare() {
    String _shareText =
        "$_title by $_govt Govt.\n\n$_description\n\nFor more info visit $_url";

    if (_imgURL != null) {
      _dataSub = _handelImgDownload().asStream().listen((List data) async {
        print("entered in stream sharing.....");
        await Share.file(_title, '$_title.jpg', data, 'image/jpg',
            text: _shareText);

        Navigator.pop(context);
      });
    } else {
      Share.text(_title, _shareText, 'text/plain');
    }
  }

  void _cancelSharing() {
    Navigator.pop(context);
    _dataSub.cancel();
  }

  @override
  void initState() {
    super.initState();
    _getGovtScheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _allLoaded
          ? CustomBody(
              appBarTitle: Text(""),
              appBarTitleAfterScroll: Text(
                _govt,
                style:
                    GoogleFonts.patuaOne().copyWith(color: Colors.black87),
              ),
              appBarLeading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(FontAwesomeIcons.times,
                    color: Colors.black87, size: 20.0),
              ),
              appBarActions: <Widget>[
                IconButton(
                  tooltip: "Share",
                  icon: Icon(FontAwesomeIcons.share,
                      color: Colors.black87, size: 20.0),
                  onPressed: _handelShare,
                ),
              ],
              body: Body(
                  id: widget.id,
                  title: _title,
                  govt: _govt,
                  imgURL: _imgURL,
                  description: _description,
                  url: _url),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
