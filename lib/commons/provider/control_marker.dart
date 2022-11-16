import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/models.dart';

class ControlMarker extends ChangeNotifier {
  final List<Marker> _markers = [];

  List<Marker> get markers => _markers;

  void add(Here here) {
    _markers.add(Marker(
      markerId: MarkerId(here.hid.toString()),
      position: LatLng(here.location['x'], here.location['y']),
    ));
    notifyListeners();
  }

  void delete(int hid) {
    _markers.removeWhere((element) => element.markerId == MarkerId(hid.toString()));
    notifyListeners();
  }

  void edit() {
    notifyListeners();
  }
}