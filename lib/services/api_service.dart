import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';
import '../models/collection.dart';
import '../models/trip_report.dart';
import '../utils/constants.dart';

/// All HTTP calls to the .NET backend.
class ApiService {
  static const String _base = AppConstants.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── Screen 1 ─────────────────────────────────
  /// Fetch today's route (optimised stop sequence) from backend.
  static Future<RouteModel> fetchRoute() async {
    final uri = Uri.parse(
      '$_base/api/route?lat=${AppConstants.collectorLat}&lng=${AppConstants.collectorLng}',
    );
    final resp = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    _checkStatus(resp);
    return RouteModel.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  // ── Screen 2 ─────────────────────────────────
  /// Submit a collection record for a supplier.
  static Future<void> submitCollection(Collection c) async {
    final uri = Uri.parse('$_base/api/collections');
    final resp = await http
        .post(uri, headers: _headers, body: jsonEncode(c.toApiJson()))
        .timeout(const Duration(seconds: 15));
    _checkStatus(resp);
  }

  // ── Screen 3 ─────────────────────────────────
  /// Fetch the trip report summary.
  static Future<TripReport> fetchTripReport() async {
    final uri = Uri.parse('$_base/api/report');
    final resp = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    _checkStatus(resp);
    return TripReport.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// Batch sync – push all unsynced local records to server.
  static Future<bool> syncAll(List<Collection> records) async {
    try {
      final uri = Uri.parse('$_base/api/collections/sync');
      final body = jsonEncode(records.map((r) => r.toApiJson()).toList());
      final resp = await http
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 30));
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  static void _checkStatus(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('API error ${resp.statusCode}: ${resp.body}');
    }
  }
}
