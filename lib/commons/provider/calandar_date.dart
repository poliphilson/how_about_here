import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDate extends ChangeNotifier {
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get date => _date;

  void setDate(String specificDate) {
    _date = specificDate;
  }
}