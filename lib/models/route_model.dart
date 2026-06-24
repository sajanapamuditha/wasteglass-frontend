import 'supplier.dart';

class RouteModel {
  final List<Supplier> stops;
  final double totalDistanceKm;

  RouteModel({required this.stops, required this.totalDistanceKm});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final stopList = (json['stops'] as List)
        .map((s) => Supplier.fromJson(s as Map<String, dynamic>))
        .toList();
    return RouteModel(
      stops:            stopList,
      totalDistanceKm:  (json['totalDistanceKm'] as num).toDouble(),
    );
  }
}
