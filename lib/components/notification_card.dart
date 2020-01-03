import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/details/details_screen.dart';

import '../data_classes/user_data.dart';

class NotificationCard extends StatelessWidget {
  final dataID;
  final name;
  final imgURL;
  final detailedStatus;

  const NotificationCard({
    Key key,
    @required this.dataID,
    @required this.name,
    @required this.imgURL,
    @required this.detailedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Material(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Details(
                          id: dataID,
                        )));
            Firestore.instance
                .document('users/${userData.uid}/notifications/$dataID')
                .delete();
          },
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(imgURL),
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        detailedStatus,
                        style: TextStyle(color: Color(0xFF707070)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
