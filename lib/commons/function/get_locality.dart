import 'package:geocoding/geocoding.dart';

String getLocality(Placemark placemark) {
  String locality = '???';

  if (placemark.name != '') {
    locality = placemark.name!;
    return locality;
  } 

  if (placemark.street != '') {
    locality = placemark.street!;
    return locality;
  } 

  if (placemark.subLocality != '') {
    locality = placemark.subLocality!;
    return locality;
  } 

  if (placemark.locality != '') {
    locality = placemark.locality!;
    return locality;
  } 

  if (placemark.administrativeArea != '') {
    locality = placemark.administrativeArea!;
    return locality;
  }

  return locality;
}