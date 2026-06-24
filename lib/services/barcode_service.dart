/// Decodes a raw barcode string and extracts the supplier ID.
/// The barcode encodes just the supplier ID as a plain integer string.
/// e.g. "SUP-001"  or  "1"  – we trim and parse the numeric part.
class BarcodeService {
  /// Returns the supplier ID integer, or null if the barcode is invalid.
  static int? decode(String rawValue) {
    final trimmed = rawValue.trim();
    // Handle "SUP-001" style barcodes
    final stripped = trimmed.replaceFirst(RegExp(r'^SUP-0*', caseSensitive: false), '');
    return int.tryParse(stripped.isNotEmpty ? stripped : trimmed);
  }
}
