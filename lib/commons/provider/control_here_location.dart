import 'package:flutter/material.dart';

class ControlHereLocation extends ChangeNotifier {
  String _locality = 'Hmm...';
  String _area = ' ';
  late double _latitude;
  late double _longitude;

  String get locality => _locality;
  String get area => _area;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void setLocality(String locality) {
    _locality = locality;
    notifyListeners();
  }

  void setArea(String area) {
    _area = area;
    notifyListeners();
  }

  void setLatitude(double latitude) {
    _latitude = latitude;
  }

  void setLongitude(double longitude) {
    _longitude = longitude;
  }
}