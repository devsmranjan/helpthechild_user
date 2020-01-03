import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import 'package:help_the_child_user/components/custom_center.dart';
import 'package:help_the_child_user/data_classes/profile_data.dart';
import 'package:help_the_child_user/data_classes/profile_data_repo.dart';
import '../details/body.dart';

class Details extends StatefulWidget {
  final id;

  const Details({Key key, @required this.id}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  StreamSubscription<List> _dataSub;
  bool _isLoading = true;

  ProfileData _profileData;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _getProfileData() async {
    var profile = await ProfileRepository(id: widget.id).getProfileData();

    Firestore.instance.document('data/${widget.id}').get().then((document) {
      _profileData = ProfileData(
          id: profile['id'],
          name: profile['name'],
          imgURL: profile['imgURL'],
          dist: profile['dist'],
          dateOfUpload: profile['dateOfUpload'],
          timeOfUpload: profile['timeOfUpload'],
          status: profile['status'],
          detailedStatus: profile['detailedStatus'],
          address:profile['address'],
              
          description: profile['description'],
          gender: profile['gender'],
          lastStatusUpdateDateAndTime: profile['lastStatusUpdateDateAndTime'],
          latitude: profile['latitude'],
          longitude: profile['longitude'],
          senderID: profile['senderID']);

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  void _deleteData() {
    final DocumentReference _childDocRef =
        Firestore.instance.document('data/${_profileData.getID}');

    _childDocRef.delete();
    FirebaseStorage().getReferenceFromUrl(_profileData.getImgURL).then((ref) {
      ref.delete();
    });

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Succesfully deleted."),
    ));

    // Future.delayed(const Duration(milliseconds: 1000), () {
    Navigator.pop(context);
    Flushbar(
      message: "Successfuly deleted.",
      duration: Duration(seconds: 3),
    )..show(context);
    // });
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
    var request = await HttpClient().getUrl(Uri.parse(_profileData.getImgURL));
    print("Request done.....");
    var response = await request.close();
    print("Response done.....");
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    print("bytes done.....");

    return bytes;
  }

  void _handelShare() {
    String _shareText =
        "Hey! I found this child near ${_profileData.getAddress}.\nIf you know anything about this child please let me know.";

    _dataSub = _handelImgDownload().asStream().listen((List data) async {
      print("entered in stream sharing.....");
      await Share.file(_profileData.getName, '${_profileData.getName}.jpg',
          data, 'image/jpg',
          text: _shareText);

      Navigator.pop(context);
    });
  }

  void _cancelSharing() {
    Navigator.pop(context);
    _dataSub.cancel();
  }

  void _handlePopupMenuAction(String value) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Are you sure to delete?",
              style: TextStyle(fontSize: 18.0),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("NO"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteData();
                },
                child: Text("YES"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: CustomBody(
          appBarTitle: Container(),
          appBarTitleAfterScroll: !_isLoading
              ? Text(_profileData.getName,
                  style: GoogleFonts.patuaOne().copyWith(color: Colors.black87))
              : Text(""),
          appBarLeading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft,
                color: Colors.black87, size: 20.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          appBarActions: !_isLoading
              ? <Widget>[
                  IconButton(
                    tooltip: "Share",
                    icon: Icon(FontAwesomeIcons.share,
                        color: Colors.black87, size: 20.0),
                    onPressed: _handelShare,
                  ),
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection('data')
                        .where('id', isEqualTo: _profileData.getID)
                        .limit(1)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      

                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length >= 1) {
                          if (snapshot.data.documents[0].data['status'] ==
                              "sent") {
                            return PopupMenuButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(FontAwesomeIcons.ellipsisV,
                                    color: Colors.black87, size: 20.0),
                                itemBuilder: (_) => <PopupMenuItem<String>>[
                                      PopupMenuItem<String>(
                                          child: const Text('Delete'),
                                          value: 'delete'),
                                    ],
                                onSelected: (value) {
                                  _handlePopupMenuAction(value);
                                });
                          }
                        } else {
                          return Container();
                        }
                      }

                      return Container();
                    },
                  ),
                ]
              : [],
          body: !_isLoading
              ? Body(profileData: _profileData)
              : CustomCenter(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
