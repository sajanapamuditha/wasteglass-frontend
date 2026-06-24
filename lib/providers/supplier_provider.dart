import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../models/route_model.dart';
import '../services/api_service.dart';

class SupplierProvider extends ChangeNotifier {
  RouteModel? _route;
  bool _loading = false;
  String? _error;

  RouteModel? get route => _route;
  bool get loading => _loading;
  String? get error => _error;

  List<Supplier> get stops => _route?.stops ?? [];

  Supplier? get currentStop {
    try {
      return stops.firstWhere((s) => s.status == 'Next');
    } catch (_) {
      return null;
    }
  }

  int get remainingCount => stops.where((s) => s.status != 'Collected').length;

  Future<void> loadRoute() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _route = await ApiService.fetchRoute();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  /// Mark the stop with [supplierId] as Collected and promote next to Next.
  void markCollected(int supplierId) {
    final idx = stops.indexWhere((s) => s.id == supplierId);
    if (idx == -1) return;
    stops[idx].status = 'Collected';

    // Find next pending stop and mark it as Next
    final nextIdx = stops.indexWhere((s) => s.status == 'Pending');
    if (nextIdx != -1) stops[nextIdx].status = 'Next';

    notifyListeners();
  }

  bool get allDone =>
      stops.isNotEmpty && stops.every((s) => s.status == 'Collected');
}
