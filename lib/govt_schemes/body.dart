import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help_the_child_user/components/custom_center.dart';
import 'package:help_the_child_user/components/scheme_card.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('govtSchemes').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData) {
          if (snapshot.data.documents.length <= 0) {
            return CustomCenter(
              child: Text("No schemes available for now."),
            );
          }
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CustomCenter(child: CircularProgressIndicator());

          default:
            return ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return SchemeCard(
                    id: snapshot.data.documents[index].data['id'],
                    schemeName: snapshot.data.documents[index].data['title'],
                    govt: snapshot.data.documents[index].data['govt'],
                  );
                });
        }
      },
    );
  }
}
