import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class ControlHereLocation extends ChangeNotifier {
  String _locality = 'Hmm...';
  String _area = ' ';
  late double _latitude;
  late double _longitude;
  late Placemark _placemark;
  String _time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  String get locality => _locality;
  String get area => _area;
  double get latitude => _latitude;
  double get longitude => _longitude;
  Placemark get placemark => _placemark;
  String get time => _time;

  void setPlacemark(Placemark placemark) {
    _placemark = placemark;
  }

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

  void setTime(String time) {
    _time = time;
  }
}