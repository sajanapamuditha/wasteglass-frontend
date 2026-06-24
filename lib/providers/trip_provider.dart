import 'package:flutter/material.dart';
import '../models/trip_report.dart';
import '../services/api_service.dart';

class TripProvider extends ChangeNotifier {
  TripReport? _report;
  bool        _loading = false;
  String?     _error;
  DateTime?   _tripStart;

  TripReport? get report   => _report;
  bool        get loading  => _loading;
  String?     get error    => _error;
  DateTime?   get tripStart => _tripStart;

  void startTrip() {
    _tripStart = DateTime.now();
    notifyListeners();
  }

  Future<void> loadReport() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _report = await ApiService.fetchTripReport();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
