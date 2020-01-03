// import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class LocationDetails {
  Future<Map<String, dynamic>> getLocationData() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "country": placemark[0].country,
      "locality": placemark[0].locality,
      "administrativeArea": placemark[0].administrativeArea,
      "postalCode" : placemark[0].postalCode,
      "name" : placemark[0].name,
      "subAdministrativeArea": placemark[0].subAdministrativeArea,
      "isoCountryCode": placemark[0].isoCountryCode,
      "subLocality": placemark[0].subLocality,
      "subThoroughfare": placemark[0].subThoroughfare,
      "thoroughfare": placemark[0].thoroughfare,
    };
  }
}
