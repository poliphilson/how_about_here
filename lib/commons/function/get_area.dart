import 'package:geocoding/geocoding.dart';

String getArea(Placemark placemark) {
  String area = '???';

  if (placemark.administrativeArea != '') {
    return placemark.administrativeArea!;
  }

  if (placemark.country != '') {
    return placemark.country!;
  }
  
  return area;
}