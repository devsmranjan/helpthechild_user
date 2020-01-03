import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/components/custom_center.dart';
import 'package:help_the_child_user/components/profile_card.dart';
import '../home/profile_card_data.dart';
import 'home_screen.dart';

class HomeView extends StatefulWidget {
  final auth;
  final filterOption;

  const HomeView({Key key, @required this.auth, @required this.filterOption})
      : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _uid;
  String _statusValue = null;

  Future _getCurrentUserData() async {
    Map<String, dynamic> _currentUser = await widget.auth.currentUser();
    setState(() {
      _uid = _currentUser['uid'];
    });
  }

  @override
  void initState() {
    _getCurrentUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('data')
              .where('userID', isEqualTo: _uid)
              .where('status', isEqualTo: widget.filterOption)
              .orderBy("id", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // print("Length" + snapshot.data.documents.length.toString());
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              if (snapshot.data.documents.length <= 0) {
                return CustomCenter(
                  child: Text("No data available"),
                );
              }
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CustomCenter(child: CircularProgressIndicator());

              default:
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return ProfileCard(
                      id: snapshot.data.documents[index].data['id'],
                    );
                  },
                );
            }
          },
        ));
  }
}
