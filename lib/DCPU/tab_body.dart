import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/components/dcpo_card.dart';

class TabBody extends StatefulWidget {
  final state;

  const TabBody({Key key, @required this.state}) : super(key: key);

  @override
  _TabBodyState createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('dcpu')
          .where("state", isEqualTo: widget.state)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData) {
          if (snapshot.data.documents.length <= 0) {
            return Center(
              child: Text("No districts found."),
            );
          }
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return DCPOCard(
                  id: snapshot.data.documents[index].data['id'],
                  dist: snapshot.data.documents[index].data['dist'],
                  dcpoName: snapshot.data.documents[index].data['dcpo'],
                  contactNumber: snapshot.data.documents[index].data['officeTelephoneNo'],
                );
              },
            );
        }
      },
    );
  }
}
