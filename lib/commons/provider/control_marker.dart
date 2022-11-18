import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/models.dart';

class ControlMarker extends ChangeNotifier {
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

  void edit() {
    notifyListeners();
  }
}