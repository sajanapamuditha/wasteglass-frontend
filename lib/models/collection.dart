// Represents a single collection record (stored locally + synced to server)

class Collection {
  final int?   localId;     // SQLite row id
  final int    supplierId;
  final double clearKg;
  final double colouredKg;
  final String condition;   // Good | Fair | Poor
  final DateTime timestamp;
  bool   synced;            // has been pushed to server

  Collection({
    this.localId,
    required this.supplierId,
    required this.clearKg,
    required this.colouredKg,
    required this.condition,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (localId != null) 'id': localId,
      'supplier_id':  supplierId,
      'clear_kg':     clearKg,
      'coloured_kg':  colouredKg,
      'condition':    condition,
      'timestamp':    timestamp.toIso8601String(),
      'synced':       synced ? 1 : 0,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      localId:    map['id'] as int?,
      supplierId: map['supplier_id'] as int,
      clearKg:    (map['clear_kg'] as num).toDouble(),
      colouredKg: (map['coloured_kg'] as num).toDouble(),
      condition:  map['condition'] as String,
      timestamp:  DateTime.parse(map['timestamp'] as String),
      synced:     (map['synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'supplierId':  supplierId,
      'clearKg':     clearKg,
      'colouredKg':  colouredKg,
      'condition':   condition,
      'timestamp':   timestamp.toIso8601String(),
    };
  }
}
