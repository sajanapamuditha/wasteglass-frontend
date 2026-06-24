class ReportSupplier {
  final int    supplierId;
  final String supplierName;
  final double expectedClearKg;
  final double expectedColouredKg;
  final double collectedClearKg;
  final double collectedColouredKg;
  final String condition;
  final bool   hasShortfall;

  ReportSupplier({
    required this.supplierId,
    required this.supplierName,
    required this.expectedClearKg,
    required this.expectedColouredKg,
    required this.collectedClearKg,
    required this.collectedColouredKg,
    required this.condition,
    required this.hasShortfall,
  });

  factory ReportSupplier.fromJson(Map<String, dynamic> json) {
    return ReportSupplier(
      supplierId:           json['supplierId'] as int,
      supplierName:         json['supplierName'] as String,
      expectedClearKg:      (json['expectedClearKg'] as num).toDouble(),
      expectedColouredKg:   (json['expectedColouredKg'] as num).toDouble(),
      collectedClearKg:     (json['collectedClearKg'] as num).toDouble(),
      collectedColouredKg:  (json['collectedColouredKg'] as num).toDouble(),
      condition:            json['condition'] as String,
      hasShortfall:         json['hasShortfall'] as bool,
    );
  }
}

class TripReport {
  final List<ReportSupplier> suppliers;
  final double totalClearKg;
  final double totalColouredKg;
  final double totalKg;
  final double routeDistanceKm;
  final int    tripDurationMinutes;

  TripReport({
    required this.suppliers,
    required this.totalClearKg,
    required this.totalColouredKg,
    required this.totalKg,
    required this.routeDistanceKm,
    required this.tripDurationMinutes,
  });

  factory TripReport.fromJson(Map<String, dynamic> json) {
    return TripReport(
      suppliers:           (json['suppliers'] as List)
          .map((s) => ReportSupplier.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalClearKg:        (json['totalClearKg'] as num).toDouble(),
      totalColouredKg:     (json['totalColouredKg'] as num).toDouble(),
      totalKg:             (json['totalKg'] as num).toDouble(),
      routeDistanceKm:     (json['routeDistanceKm'] as num).toDouble(),
      tripDurationMinutes: json['tripDurationMinutes'] as int,
    );
  }
}
