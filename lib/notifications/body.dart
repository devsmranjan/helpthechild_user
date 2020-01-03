import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/components/custom_center.dart';
import '../components/notification_card.dart';
import '../data_classes/user_data.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('users/${userData.uid}/notifications')
                .orderBy("id")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.hasData) {
                if (snapshot.data.documents.length <= 0) {
                  return CustomCenter(
                    child: Text("No notifications available"),
                  );
                }
              }

              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CustomCenter(child: CircularProgressIndicator());
                default:
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return NotificationCard(
                        dataID: snapshot.data.documents[index].data['dataID'],
                        name: snapshot.data.documents[index].data['name'],
                        imgURL: snapshot.data.documents[index].data['imgURL'],
                        detailedStatus: snapshot
                            .data.documents[index].data['detailedStatus'],
                      );
                    },
                  );
              }
            }));
  }
}
