// Model for a supplier returned from the backend

class Supplier {
  final int    id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double expectedClearKg;
  final double expectedColouredKg;
  final String barcodeRef;     // encoded supplier ID for barcode
  String       status;         // Pending | Next | Collected
  final int    stopOrder;      // position in optimised route
  final double distanceFromPrev; // km from previous stop

  Supplier({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.expectedClearKg,
    required this.expectedColouredKg,
    required this.barcodeRef,
    required this.status,
    required this.stopOrder,
    required this.distanceFromPrev,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id:                   json['id'] as int,
      name:                 json['name'] as String,
      address:              json['address'] as String,
      latitude:             (json['latitude'] as num).toDouble(),
      longitude:            (json['longitude'] as num).toDouble(),
      expectedClearKg:      (json['expectedClearKg'] as num).toDouble(),
      expectedColouredKg:   (json['expectedColouredKg'] as num).toDouble(),
      barcodeRef:           json['barcodeRef'] as String,
      status:               json['status'] as String,
      stopOrder:            json['stopOrder'] as int,
      distanceFromPrev:     (json['distanceFromPrev'] as num).toDouble(),
    );
  }
}
