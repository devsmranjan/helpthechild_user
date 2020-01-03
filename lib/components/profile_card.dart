import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/data_classes/profile_data.dart';
import 'package:help_the_child_user/data_classes/profile_data_repo.dart';
import 'package:help_the_child_user/data_classes/user_data.dart';
import 'package:help_the_child_user/details/details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileCard extends StatefulWidget {
  final id;

  const ProfileCard({Key key, @required this.id}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _statusTextColor;
  bool _isLoading = true;

  ProfileData _profileData;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didUpdateWidget(ProfileCard oldWidget) {
    setState(() {
      _isLoading = true;
    });
    _getProfileData();
    super.didUpdateWidget(oldWidget);
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
          address:
              "${profile['streetAddress']}, ${profile['dist']}, ${profile['state']} ${profile['pin']},",
          description: profile['description'],
          gender: profile['gender'],
          lastStatusUpdateDateAndTime: profile['lastStatusUpdateDateAndTime'],
          latitude: profile['latitude'],
          longitude: profile['longitude'],
          senderID: profile['senderID']);

      setState(() {
        _isLoading = false;
      });

      _statusColor(_profileData.getStatus);
    });
  }

  void _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "sent":
        _statusTextColor = 0xFF2196F3;
        break;
      case "on review":
        _statusTextColor = 0xFFDBA716;
        break;
      case "accepted":
        _statusTextColor = 0xFF16DB3C;
        break;
      case "rejected":
        _statusTextColor = 0xFFF44336;
        break;
    }
  }

  @override
  void initState() {
    _getProfileData();

    super.initState();
  }

  Widget _statusContainer() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('data')
          .where('id', isEqualTo: _profileData.getID)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var status;

        if (snapshot.hasData && snapshot.data.documents.length >= 1) {
          status = snapshot.data.documents[0].data['status'];
          if (status != null) {
            _statusColor(status.toString());
          }
        }

        return Text(
          status.toString().toUpperCase(),
          style: TextStyle(
              color: Color(_statusTextColor),
              letterSpacing: 1.2,
              fontSize: 12.0,
              fontWeight: FontWeight.w600),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: 168.0,
        child: !_isLoading
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Details(
                                id: widget.id,
                              )));
                },
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        child: CachedNetworkImage(
                          imageUrl: _profileData.getImgURL,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: const Color(0xFF000000).withOpacity(0.5)),
                    ),
                    Positioned.fill(
                      bottom: 12.0,
                      left: 12.0,
                      right: 12.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          _statusContainer(),
                          FittedBox(
                            child: Text(
                              _profileData.getName,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.0),
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      size: 18.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                      _profileData.getDist,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.today,
                                      size: 18.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                      _profileData.getDateOfUpload,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ))
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
