import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_the_child_user/DCPU/tab_body.dart';

class DCPU extends StatefulWidget {
  @override
  _DCPUState createState() => _DCPUState();
}

class _DCPUState extends State<DCPU> {
  List<String> _stateList = [];

  void _fetchStates() {
    Firestore.instance
        .collection('dcpu')
        .orderBy('state')
        .getDocuments()
        .then((snapshot) {
      _stateList.clear();
      for (DocumentSnapshot doc in snapshot.documents) {
        var stateValue = doc['state'];

        if (!_stateList.contains(stateValue)) {
          setState(() {
            _stateList.add(stateValue);
          });
        }
      }
      print(_stateList);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _stateList.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          title: Text(
            "DCPU of India",
            style: GoogleFonts.patuaOne().copyWith(color: Colors.black87),
          ),
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft,
                color: Colors.black87, size: 20.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor:
                  Theme.of(context).primaryColor.withOpacity(0.3),
              indicatorColor: Theme.of(context).primaryColor,
              tabs: _stateList
                  .map((state) => Tab(
                          child: Text(
                        state.toUpperCase(),
                      )))
                  .toList()),
        ),
        body: _stateList.length >= 1
            ? TabBarView(
                children: _stateList
                    .map((state) => TabBody(
                          state: state,
                        ))
                    .toList(),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
