import 'package:flutter/material.dart';

class ProgressIndicatorStatus extends ChangeNotifier {
  bool _status = false;

  bool get status => _status;

  void on() {
    _status = true;
    notifyListeners();
  }

  void off() {
    _status = false;
    notifyListeners();
  }
}