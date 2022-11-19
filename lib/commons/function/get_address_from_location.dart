import 'package:geocoding/geocoding.dart';

Future<Placemark> getAddressFromLocation(double latitude, double longitude) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
  return placemarks[0];
}