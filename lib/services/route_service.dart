import '../models/supplier.dart';

/// Client-side helper (the real Dijkstra runs on the backend).
/// This just exposes a simple util to find the next pending stop.
class RouteService {
  static Supplier? nextStop(List<Supplier> stops) {
    try {
      return stops.firstWhere((s) => s.status == 'Next');
    } catch (_) {
      return null;
    }
  }

  static int remainingStops(List<Supplier> stops) =>
      stops.where((s) => s.status != 'Collected').length;
}
