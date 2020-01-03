import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future googleSignIn(); //  Google Sign In
  Future<Map<String, dynamic>> currentUser();
  Future<void> updateUserData();

  void signOut(); //  Sign Out
}

class Auth implements BaseAuth {
  Future googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication;

    try {
      googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error in google authentication");
    }
  }

  Future<Map<String, dynamic>> currentUser() async {
    Map<String, dynamic> _userData;

    FirebaseUser _user;

    try {
      _user = await FirebaseAuth.instance.currentUser();
    } catch (e) {
      print(e);
    }

    _userData = <String, dynamic>{
      "uid": _user.uid,
      "photoUrl": _user.photoUrl,
      "displayName": _user.displayName,
      "email": _user.email,
      "isAnonymous": _user.isAnonymous,
      "isEmailVerified": _user.isEmailVerified,
      "providerData": _user.providerData,
    };
    return _userData;
  }

  Future<void> updateUserData({String photoURL}) async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.photoUrl = photoURL;
    _user.updateProfile(userUpdateInfo).catchError((err) {
      print(err);
    }).whenComplete(() {
      print("Updated");
      _user.reload();
    });
    
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
  }
}
