import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/custom_center.dart';
import '../location_details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/dcpo_card.dart';

class NearByDCPOView extends StatefulWidget {
  @override
  _NearByDCPOViewState createState() => _NearByDCPOViewState();
}

class _NearByDCPOViewState extends State<NearByDCPOView> {
  Map<String, dynamic> _locationData;
  bool _isLoading = false;
  String _address;
  String _dist;

  @override
  void initState() {
    _handelRefresh();
    super.initState();
  }

  void _handelRefresh() {
    setState(() {
      _isLoading = true;
    });
    LocationDetails locationDetails = LocationDetails();
    locationDetails.getLocationData().then((locationData) {
      setState(() {
        _locationData = locationData;
        _dist = _locationData['subAdministrativeArea'];
        _address =
            "${_locationData['subLocality']}, ${_locationData['locality']}, ${_locationData['subAdministrativeArea']}, ${_locationData['administrativeArea']} ${_locationData['postalCode']}";
        _address = _address[0] == ","
            ? _address.replaceFirst(",", "").trim()
            : _address;
        _isLoading = false;
      });
    });
  }

  Widget _locationWidget(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: _handelRefresh,
        child: Container(
          padding: EdgeInsets.all(18.0),
          child: !_isLoading
              ? Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.mapPin,
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(
                      width: 18.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "You are now in",
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF707070)),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          Text(_address),
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget _getDCPO() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('dcpu')
          .where('dist', isEqualTo: _dist)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          if (snapshot.data.documents.length <= 0) {
            return CustomCenter(
              extraValue: 140,
              child: Text("No DCPU found"),
            );
          }
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CustomCenter(
                extraValue: 140, child: CircularProgressIndicator());

          default:
            return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 4.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return DCPOCard(
                  id: snapshot.data.documents[index].data['id'],
                  dcpoName: snapshot.data.documents[index].data['dcpo'],
                  dist: snapshot.data.documents[index].data['dist'],
                  contactNumber:
                      snapshot.data.documents[index].data["officeTelephoneNo"],
                );
              },
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _locationWidget(context),
        Divider(
          height: 0.0,
        ),
        _dist != null ? _getDCPO() : Container(),
      ],
    );
  }
}
