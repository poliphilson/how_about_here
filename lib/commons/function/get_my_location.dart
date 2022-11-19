import 'package:geolocator/geolocator.dart';

Future<Position> getMyLocation() async {
  await Geolocator.requestPermission();
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  return position;
}