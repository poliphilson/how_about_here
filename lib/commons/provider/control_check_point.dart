import 'package:flutter/material.dart';
import 'package:here/models.dart';

class ControlCheckPoint extends ChangeNotifier {
  final List<Point> _points = [];

  List<Point> get points => _points;

  void add(List<Point> newPoints) {
    _points.addAll(newPoints);
    notifyListeners();
  }

  void delete(int index) {
    _points.removeAt(index);
    notifyListeners();
  }

  void edit(int index, String description) {
    _points[index].description = description;
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }
}