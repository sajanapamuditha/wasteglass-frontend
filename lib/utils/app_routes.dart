import 'package:flutter/material.dart';
import '../screens/trip_sequence_screen.dart';
import '../screens/scan_collect_screen.dart';
import '../screens/trip_report_screen.dart';

class AppRoutes {
  static const String tripSequence = '/';
  static const String scanCollect  = '/scan';
  static const String tripReport   = '/report';

  static Map<String, WidgetBuilder> routes = {
    tripSequence: (_) => const TripSequenceScreen(),
    scanCollect:  (_) => const ScanCollectScreen(),
    tripReport:   (_) => const TripReportScreen(),
  };
}
