import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/components/custom_body.dart';
import 'package:image_picker/image_picker.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data_classes/user_data.dart';
import '../donation/donation_screen.dart';
import '../govt_schemes/govt_schemes_screen.dart';
import '../DCPU/dcpu_screen.dart';
import '../rewards/rewards_screen.dart';
import '../profile/profile_screen.dart';
import '../upload/upload_screen.dart';
import '../notifications/notification_screen.dart';
import 'home.dart';
import 'nearby_dcpo.dart';

enum FilterOption { all, sent, accepted, onReview, rejected }

class Home extends StatefulWidget {
  final auth;
  final onSignedOut;

  const Home({Key key, @required this.auth, @required this.onSignedOut})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FilterOption _filterOption = FilterOption.all;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _selectedIndex = 0;
  String _uid;
  bool _isLoading = true;

  List<Widget> _bottomBarOptions;

  Future _getUserData() async {
    Map<String, dynamic> _currentUser = await widget.auth.currentUser();

    // setState(() {
    _uid = _currentUser['uid'];
    // });

    DocumentReference _docRefForUserProfile =
        Firestore.instance.document('users/$_uid');
    _docRefForUserProfile.get().then((document) {
      // user Data
      userData.uid = document['uid'];
      userData.displayName = document['name'];
      userData.photoURL = document['photoURL'];
      userData.email = document['email'];
      userData.phone = document['phone'];
      userData.address = document['address'];
      userData.isAnonymous = _currentUser['isAnonymous'];
      userData.isEmailVerified = _currentUser['isEmailVerified'];
      userData.providerData = _currentUser['providerData'];
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    _getUserData();
    _bottomBarOptions = <Widget>[
      HomeView(
        auth: widget.auth,
        filterOption: null,
      ),
      NearByDCPOView()
    ];
    super.initState();
  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Upload(
                    image: image,
                  ),
              fullscreenDialog: true));
    }
  }

  Widget _buildDrawer() {
    return Drawer(
        child: Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  child: !_isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Profile(auth: widget.auth)));
                              },
                              child: Hero(
                                tag: 'Profile Photo',
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundImage: CachedNetworkImageProvider(
                                      userData.photoURL),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            FittedBox(
                              child: Text(
                                userData.displayName,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            SizedBox(
                              height: 2.0,
                            ),
                            FittedBox(
                              child: Text(
                                userData.email,
                                style: TextStyle(
                                    fontSize: 12.0, color: Color(0xFF707070)),
                              ),
                            )
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
              ListTile(
                leading: Icon(Icons.redeem),
                title: Text('My Rewards'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Rewards()));
                },
              ),
              ListTile(
                leading: Icon(Icons.child_care),
                title: Text('DCPU of India'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => DCPU()));
                },
              ),
              ListTile(
                leading: Icon(Icons.book),
                title: Text('All Govt Schemes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GovtSchemes()));
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Send Donation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Donation()));
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share this App'),
                onTap: () async {
                  Navigator.pop(context);
                  final ByteData bytes =
                      await rootBundle.load('assets/logo/logo_square.png');
                  await Share.file('Help the child', 'helpthechild.png',
                      bytes.buffer.asUint8List(), 'image/png',
                      text:
                          'Let\'s contribute together for a better India.\nDownload Help the child app from here https://smrutiranjanrana.github.io');
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Are you sure to sign out?",
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
                                widget.auth.signOut();
                                widget.onSignedOut();
                              },
                              child: Text("YES"),
                            )
                          ],
                        );
                      },
                      barrierDismissible: false);
                },
              ),
            ],
          ),
        ),
        ListTile(
          onTap: () {
            launch("tel:1098");
          },
          title: Text("Call Child Helpline"),
          trailing: Icon(Icons.call),
        )
      ],
    ));
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _bottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          title: Text(
            'Nearby DCPO',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black87,
      onTap: _onBottomNavItemTapped,
    );
  }

  void _buildBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(4.0),
                    topRight: const Radius.circular(4.0))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 24.0,
                  height: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                RadioListTile<FilterOption>(
                  title: const Text('All'),
                  value: FilterOption.all,
                  groupValue: _filterOption,
                  onChanged: (FilterOption value) {
                    Navigator.pop(context);
                    setState(() {
                      _filterOption = value;
                      _bottomBarOptions = <Widget>[
                        HomeView(
                          auth: widget.auth,
                          filterOption: null,
                        ),
                        NearByDCPOView()
                      ];
                    });
                  },
                ),
                RadioListTile<FilterOption>(
                  title: const Text('Sent'),
                  value: FilterOption.sent,
                  groupValue: _filterOption,
                  onChanged: (FilterOption value) {
                    Navigator.pop(context);
                    setState(() {
                      _filterOption = value;
                      _bottomBarOptions = <Widget>[
                        HomeView(
                          auth: widget.auth,
                          filterOption: "sent",
                        ),
                        NearByDCPOView()
                      ];
                    });
                  },
                ),
                RadioListTile<FilterOption>(
                  title: const Text('On Review'),
                  value: FilterOption.onReview,
                  groupValue: _filterOption,
                  onChanged: (FilterOption value) {
                    Navigator.pop(context);
                    setState(() {
                      _filterOption = value;
                      _bottomBarOptions = <Widget>[
                        HomeView(
                          auth: widget.auth,
                          filterOption: "on review",
                        ),
                        NearByDCPOView()
                      ];
                    });
                  },
                ),
                RadioListTile<FilterOption>(
                  title: const Text('Accepted'),
                  value: FilterOption.accepted,
                  groupValue: _filterOption,
                  onChanged: (FilterOption value) {
                    Navigator.pop(context);
                    setState(() {
                      _filterOption = value;
                      _bottomBarOptions = <Widget>[
                        HomeView(
                          auth: widget.auth,
                          filterOption: "accepted",
                        ),
                        NearByDCPOView()
                      ];
                    });
                  },
                ),
                RadioListTile<FilterOption>(
                  title: const Text('Rejected'),
                  value: FilterOption.rejected,
                  groupValue: _filterOption,
                  onChanged: (FilterOption value) {
                    Navigator.pop(context);
                    setState(() {
                      _filterOption = value;
                      _bottomBarOptions = <Widget>[
                        HomeView(
                          auth: widget.auth,
                          filterOption: "rejected",
                        ),
                        NearByDCPOView()
                      ];
                    });
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: _uid != null
          ? CustomBody(
              appBarTitle: Text(
                "Help The Child",
                style:
                    GoogleFonts.patuaOne().copyWith(color: Colors.black87),
              ),
              appBarLeading: IconButton(
                icon: Icon(FontAwesomeIcons.stream,
                    color: Colors.black87, size: 20.0),
                onPressed: () {
                  // drawer
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              appBarActions: <Widget>[
                _selectedIndex != 1
                    ? IconButton(
                        tooltip: "Filter",
                        icon: Icon(FontAwesomeIcons.filter,
                            color: Colors.black87, size: 20.0),
                        onPressed: _buildBottomSheet,
                      )
                    : Container(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                  },
                  icon: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users/$_uid/notifications')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Container();
                      }

                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length >= 1) {
                          return Stack(children: <Widget>[
                            Icon(FontAwesomeIcons.bell,
                                color: Colors.black87, size: 20.0),
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: Icon(Icons.brightness_1,
                                  size: 12.0, color: Colors.redAccent),
                            )
                          ]);
                        }
                      }

                      return Icon(FontAwesomeIcons.bell,
                          color: Colors.black87, size: 20.0);
                    },
                  ),
                )
              ],
              body: _bottomBarOptions.elementAt(_selectedIndex),
            )
          : Container(),
      drawer: _buildDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.plus),
        onPressed: () {
          _getImage();
        },
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }
}
