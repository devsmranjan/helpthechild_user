class UserData {
  static final UserData _userData = UserData._internal();
  String uid;
  String photoURL;
  String displayName;
  String email;
  String phone;
  String address; 
  bool isAnonymous;
  bool isEmailVerified;
  var providerData;

  factory UserData() {
    return _userData;
  }

  UserData._internal();
}

final userData = UserData();