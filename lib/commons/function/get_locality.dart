import 'package:geocoding/geocoding.dart';

String getLocality(Placemark placemark) {
  String locality = '';
  int count = 0;

  if (placemark.name != '') {
    locality = placemark.name!;
    count++;
  } 

  if (placemark.street != '') {
    locality = '$locality, ${placemark.street!}';
    count++;
  } 

  if (placemark.subLocality != '') {
    if (count == 2){
      return locality;
    }
    locality = '$locality, ${placemark.subLocality!}';
    count++;
  } 

  if (placemark.locality != '') {
    if (count == 2){
      return locality;
    }
    locality = '$locality, ${placemark.locality!}';
    count++;
  } 

  if (placemark.administrativeArea != '') {
    if (count == 2){
      return locality;
    }
    locality = '$locality, ${placemark.administrativeArea!}';
    count++;
  }
  
  if (locality == '') {
    return '???';
  }

  return locality;
}