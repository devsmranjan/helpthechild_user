import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../data_classes/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Body extends StatefulWidget {
  final auth;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Body({Key key, @required this.auth, @required this.scaffoldKey})
      : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;

  TextEditingController _userNameController;
  TextEditingController _emailController;
  TextEditingController _phoneController;
  TextEditingController _addressController;

  File _updatedProfilePhoto;

  Future<String> _photoURLDownloadURL() async {
    final profileURLPath = "${userData.uid}/profile";

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

    pr.show();

    // Storage upload
    final StorageReference profileImageStorageReference =
        FirebaseStorage().ref().child(profileURLPath);
    final StorageUploadTask profileImageUploadTask =
        profileImageStorageReference.putFile(_updatedProfilePhoto);

    // Stream
    final StreamSubscription<StorageTaskEvent> profileImageStreamSubscription =
        profileImageUploadTask.events.listen((event) {
      print("profileImageUploadTask EVENT : ${event.type}");

      double progress = ((event.snapshot.bytesTransferred /
                  _updatedProfilePhoto.lengthSync()) *
              100)
          .roundToDouble();
      if (progress >= 100.0) {
        pr.update(
            progress: ((event.snapshot.bytesTransferred /
                        _updatedProfilePhoto.lengthSync()) *
                    100)
                .roundToDouble(),
            message: "Completed");
      } else if (progress >= 90.0) {
        pr.update(
            progress: ((event.snapshot.bytesTransferred /
                        _updatedProfilePhoto.lengthSync()) *
                    100)
                .roundToDouble(),
            message: "Almost Done");
      } else if (progress >= 60.0) {
        pr.update(
            progress: ((event.snapshot.bytesTransferred /
                        _updatedProfilePhoto.lengthSync()) *
                    100)
                .roundToDouble(),
            message: "Few more seconds");
      } else if (progress >= 30.0) {
        pr.update(
            progress: ((event.snapshot.bytesTransferred /
                        _updatedProfilePhoto.lengthSync()) *
                    100)
                .roundToDouble(),
            message: "Please wait");
      }
      pr.update(
        progress: ((event.snapshot.bytesTransferred /
                    _updatedProfilePhoto.lengthSync()) *
                100)
            .roundToDouble(),
      );
    });
    await profileImageUploadTask.onComplete;
    profileImageStreamSubscription.cancel();
    var profileImageDownloadURL =
        (await profileImageStorageReference.getDownloadURL()).toString();

    return profileImageDownloadURL;
  }

  Future<void> _handelUpload(BuildContext context) async {
    Map<String, dynamic> _updateData = {};

    if (_updatedProfilePhoto != null) {
      var getURL = await _photoURLDownloadURL();
      await widget.auth.updateUserData(photoURL: getURL);

      _updateData.putIfAbsent("photoURL", () => getURL);

      userData.photoURL = getURL;

      print("photoURL : " + getURL.toString());
      pr.dismiss();
    }

    _updateData.putIfAbsent("phone", () => _phoneController.text);
    _updateData.putIfAbsent("address", () => _addressController.text);

    userData.phone = _phoneController.text;
    userData.address = _addressController.text;

    if (_updateData != null) {
      Firestore.instance
          .document('users/${userData.uid}')
          .updateData(_updateData);
    }

    Flushbar(
      message: "Updating profile ...",
      duration: Duration(seconds: 3),
    )..show(context);

    // unfocus keyboard
    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _userNameController = TextEditingController(text: userData.displayName);
      _emailController = TextEditingController(text: userData.email);
      _phoneController = TextEditingController(text: userData.phone);
      _addressController = TextEditingController(text: userData.address);
    });
    pr = ProgressDialog(context,
        type: ProgressDialogType.Download,
        
        isDismissible: false,
        showLogs: true);
  }

  Future _getImageFromCamera() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _updatedProfilePhoto = image;
      });
    }
  }

  Future _getImageFromGallery() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _updatedProfilePhoto = image;
      });
    }
  }

  Widget _profilePhoto() {
    return Center(
      child: Stack(
        children: <Widget>[
          Hero(
            tag: 'Profile Photo',
            child: CircleAvatar(
              backgroundImage: _updatedProfilePhoto == null
                  ? CachedNetworkImageProvider(userData.photoURL)
                  : FileImage(_updatedProfilePhoto),
              radius: 48,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: _getImageFromCamera,
                                leading: Icon(Icons.camera_alt),
                                title: Text("Open Camera"),
                              ),
                              ListTile(
                                onTap: _getImageFromGallery,
                                leading: Icon(Icons.photo_library),
                                title: Text("Open Gallery"),
                              ),
                            ],
                          ),
                        ));
              },
              child: CircleAvatar(
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.black87,
                ),
                backgroundColor: Theme.of(context).accentColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _detailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: _userNameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Name"),
            readOnly: true,
          ),
          SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Email ID"),
            readOnly: true,
          ),
          SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Phone Number"),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Address",
            ),
            maxLines: 3,
          ),
          SizedBox(
            height: 18,
          ),
          RaisedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _handelUpload(context);
              }
            },
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            child: Text(
              'UPDATE PROFILE',
              style: TextStyle(letterSpacing: 1.0, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 18.0,
        ),
        _profilePhoto(),
        SizedBox(
          height: 18.0,
        ),
        Text(
          userData.displayName,
          style: TextStyle(fontSize: 22.0),
        ),
        SizedBox(
          height: 18.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _detailsForm(),
        )
      ],
    );
  }
}
