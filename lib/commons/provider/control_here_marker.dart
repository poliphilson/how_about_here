import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/models.dart';

class ControlHereMarker extends ChangeNotifier {
  final List<Marker> _markers = [];

  List<Marker> get markers => _markers;

  void add(Here here, double color) {
    _markers.add(Marker(
      markerId: MarkerId(here.hid.toString()),
      position: LatLng(here.location['x'], here.location['y']),
      icon: BitmapDescriptor.defaultMarkerWithHue(color)
    ));
    notifyListeners();
  }

  void delete(int hid) {
    _markers.removeWhere((element) => element.markerId == MarkerId(hid.toString()));
    notifyListeners();
  }

  void myLocation(double latitude, double longitude, double color) async {
    _markers.add(Marker(
      markerId: const MarkerId('my_location'),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(color),
    ));
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    
    _markers.removeWhere((marker) => marker.markerId == const MarkerId('my_location'));
    notifyListeners();
  }

  void edit() {
    notifyListeners();
  }

  void clear() {
    _markers.clear();
    notifyListeners();
  }
}