import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  final id;

  const Body({Key key, @required this.id}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextStyle _headingTextStyle =
      TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500);
  final TextStyle _bodyTextStyle = TextStyle(color: Color(0xFF757575));

  String _dcpo;
  String _distAndState;
  String _address;
  String _officeTelephoneNo;
  String _residenceTelephoneNo;
  String _email;
  bool _allLoaded = false;

  void _fetchDCPUData() {
    DocumentReference _dcpoDocRef =
        Firestore.instance.document('dcpu/${widget.id}');

    _dcpoDocRef.get().then((document) {
      setState(() {
        _dcpo = document['dcpo'];
        _distAndState = document['dist'] + ", " + document['state'];
        _address = document['address'];
        _officeTelephoneNo = document['officeTelephoneNo'];
        _residenceTelephoneNo = document['residenceTelephoneNo'];
        _email = document['email'];
        _allLoaded = true;
      });
    });
  }

  @override
  void initState() {
    _fetchDCPUData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _allLoaded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 14.0,
                    ),
                    Center(
                      child: Text(
                        _distAndState,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    Divider(),
                    SizedBox(
                      height: 18.0,
                    ),
                    Text(
                      "Name of the person",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _dcpo,
                      style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 14.0,
                    ),
                    Text(
                      "Dist & Sate",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _distAndState,
                      style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 14.0,
                    ),
                    Text(
                      "Official Postal Address",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _address
                      ,style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 14.0,
                    ),
                    Text(
                      "Office Telephone No.",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _officeTelephoneNo,
                      style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 14.0,
                    ),
                    Text(
                      "Residence Telephone No./ Mobile No.",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _residenceTelephoneNo,
                      style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 14.0,
                    ),
                    Text(
                      "E-Mail ID",
                      style: _headingTextStyle,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      _email,
                      style: _bodyTextStyle,
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                    Center(
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            launch("tel://$_officeTelephoneNo");
                                          },
                                          title: Text(_officeTelephoneNo),
                                          leading: Icon(Icons.call),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            launch("tel://$_residenceTelephoneNo");
                                          },
                                          title: Text(_residenceTelephoneNo),
                                          leading: Icon(Icons.call),
                                        ),
                                      ],
                                    ),
                                  ));
                        },
                        icon: Icon(Icons.call),
                        label: Text("Call Now"),
                      ),
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                  ],
                )
              : Container(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator())),
        ),
      ),
    );
  }
}
