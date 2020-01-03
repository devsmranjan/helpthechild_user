import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/custom_body.dart';
import '../components/custom_center.dart';
import '../data_classes/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../location_details.dart';

class Upload extends StatefulWidget {
  final image;

  const Upload({Key key, @required this.image}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  File _image;
  bool _isLoading = false;
  ProgressDialog pr;

  Map<String, dynamic> _locationData;

  // Form controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _streetAddressController = TextEditingController();
  TextEditingController _distController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _pinController = TextEditingController();
  TextEditingController _datetimeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _genderValue;

  Map<String, dynamic> _allInfo = {};
  // var _now = DateTime.now();
  DateTime _now = DateTime.now();

  @override
  initState() {
    setState(() {
      _image = widget.image;
    });
    pr = ProgressDialog(context,
        type: ProgressDialogType.Download,
        isDismissible: false,
        showLogs: true);

    _handelRefresh();

    super.initState();
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _streetAddressController?.dispose();
    _distController?.dispose();
    _stateController?.dispose();
    _pinController?.dispose();
    _datetimeController?.dispose();
    _descriptionController?.dispose();
    super.dispose();
  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _handelRefresh() {
    setState(() {
      _isLoading = true;
      _now = DateTime.now();
    });

    var dateFormatter = DateFormat('dd MMM yyyy');
    var timeFormatter = DateFormat('jm');

    LocationDetails locationDetails = LocationDetails();
    locationDetails.getLocationData().then((locationData) {
      setState(() {
        _locationData = locationData;

        // textfield values
        _nameController.text = "";
        _streetAddressController.text =
            "${_locationData['subLocality']}, ${_locationData['locality']}";
        _distController.text = "${_locationData['subAdministrativeArea']}";
        _stateController.text = "${_locationData['administrativeArea']}";
        _pinController.text = "${_locationData['postalCode']}";
        _datetimeController.text =
            "${dateFormatter.format(_now)} at ${timeFormatter.format(_now)}";
        _descriptionController.text = "";
        _genderValue = "";

        _isLoading = false;
      });
    });
  }

  String percentUploaded = "Preparing to upload..";

  Future<void> _handelUpload(BuildContext context) async {
    final childImagePath = "${userData.uid}/$_now-${userData.uid}";

    pr.style(
        message: 'Uploading',
        borderRadius: 4.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 8.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500));

    if (_formKey.currentState.validate()) {
      if (_genderValue != null && _genderValue != "") {
        pr.show();

        final StorageReference childImageStorageReference =
            FirebaseStorage().ref().child(childImagePath);

        final StorageUploadTask childImageUploadTask =
            childImageStorageReference.putFile(_image);

        final StreamSubscription<StorageTaskEvent>
            childImageStreamSubscription =
            childImageUploadTask.events.listen((event) {
          print('childImageUploadTask EVENT ${event.type}');

          double progress =
              ((event.snapshot.bytesTransferred / _image.lengthSync()) * 100)
                  .roundToDouble();

          if (progress >= 100.0) {
            pr.update(
                progress:
                    ((event.snapshot.bytesTransferred / _image.lengthSync()) *
                            100)
                        .roundToDouble(),
                message: "Completed");
          } else if (progress >= 90.0) {
            pr.update(
                progress:
                    ((event.snapshot.bytesTransferred / _image.lengthSync()) *
                            100)
                        .roundToDouble(),
                message: "Almost Done");
          } else if (progress >= 60.0) {
            pr.update(
                progress:
                    ((event.snapshot.bytesTransferred / _image.lengthSync()) *
                            100)
                        .roundToDouble(),
                message: "Few more seconds");
          } else if (progress >= 30.0) {
            pr.update(
                progress:
                    ((event.snapshot.bytesTransferred / _image.lengthSync()) *
                            100)
                        .roundToDouble(),
                message: "Please wait");
          }

          pr.update(
            progress:
                ((event.snapshot.bytesTransferred / _image.lengthSync()) * 100)
                    .roundToDouble(),
          );
        });
        await childImageUploadTask.onComplete;
        childImageStreamSubscription.cancel();
        var childImageDownloadUrl =
            (await childImageStorageReference.getDownloadURL()).toString();

        _allInfo.addAll({
          "id": "$_now-${userData.uid}",
          "userID": "${userData.uid}",
          "name": _nameController.text.trim() != "" ? _nameController.text.trim() : "Unknown",
          "imgURL": childImageDownloadUrl,
          "streetAddress": _streetAddressController.text[0].trim() == ","
              ? _streetAddressController.text.replaceFirst(",", "").trim()
              : _streetAddressController.text.trim(),
          "dist":
              "${_distController.text[0].toUpperCase().trim()}${_distController.text.substring(1).trim()}",
          "state": _stateController.text.trim(),
          "pin": _pinController.text.trim(),
          "gender": _genderValue,
          "dateOfUpload": _datetimeController.text.split("at")[0].trim(),
          "timeOfUpload": _datetimeController.text.split("at")[1].trim(),
          "description": _descriptionController.text.trim() != ""
              ? _descriptionController.text.trim()
              : "",
          "detailedStatus": "Data sent to nearer DCPO succesfully.",
          "lastStatusUpdateDateAndTime": "",
          "latitude": "${_locationData['latitude']}",
          "longitude": "${_locationData['longitude']}",
          "status": "sent",
        });

        print("_allInfo : " + _allInfo.toString());

        final DocumentReference _docRefForGlobalData =
            Firestore.instance.document("data/$_now-${userData.uid}");

        _docRefForGlobalData.setData(_allInfo).whenComplete(() {
          print("Successfully uploaded to docRefForGlobalData.");
          Navigator.pop(context);
          Navigator.pop(context);
        }).catchError((e) {
          print("Error in upload to docRefForGlobalData: " + e.toString());
        });
      } else {
        Flushbar(
          message: "Please choose gender",
          duration: Duration(seconds: 2),
        )..show(context);
      }
    }
  }

  Widget _photoContainer() {
    return Stack(
      children: <Widget>[
        Container(
            height: 200.0,
            child: Stack(
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    _image,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ],
            )),
        Container(
          height: 250,
        ),
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: FloatingActionButton(
            onPressed: _getImage,
            child: Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              _photoContainer(),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Name (Optional)"),
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _streetAddressController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Street Address*"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _distController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Dist*"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter dist';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "State*"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "PIN*"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter PIN';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Gender",
                style: TextStyle(
                    color: Color(0xFF707070), fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 4.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    value: "male",
                    groupValue: _genderValue,
                    onChanged: (value) {
                      setState(() {
                        _genderValue = value;
                      });
                    },
                  ),
                  Text(
                    'Male',
                  ),
                  Radio(
                    value: "female",
                    groupValue: _genderValue,
                    onChanged: (value) {
                      setState(() {
                        _genderValue = value;
                      });
                    },
                  ),
                  Text(
                    'Female',
                  ),
                  Radio(
                    value: "not sure",
                    groupValue: _genderValue,
                    onChanged: (value) {
                      setState(() {
                        _genderValue = value;
                      });
                    },
                  ),
                  Text(
                    'Not Sure',
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _datetimeController,
                readOnly: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Date & Time*"),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Description (Optional)"),
              ),
              SizedBox(
                height: 24,
              ),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                onPressed: () {
                  _handelUpload(context);
                },
                child: Text(
                  'Upload Now'.toUpperCase(),
                  style: TextStyle(letterSpacing: 1.0, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: CustomBody(
          appBarTitle: Text(
            "Upload new info",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
          ),
          appBarTitleAfterScroll: Text(
            "Upload new info",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
          ),
          appBarLeading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:
                Icon(FontAwesomeIcons.times, color: Colors.black87, size: 20.0),
          ),
          appBarActions: <Widget>[
            IconButton(
              tooltip: "Refresh",
              icon: Icon(FontAwesomeIcons.redoAlt,
                  color: Colors.black87, size: 20.0),
              onPressed: _handelRefresh,
            ),
          ],
          body: !_isLoading
              ? _body(context)
              : CustomCenter(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}
