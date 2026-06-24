// lib/screens/trip_report_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/report_tile.dart';

/// Screen 3 – Trip summary and sync.
class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Trip Report'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Trip is done, no back button
      ),
      body: Consumer2<TripProvider, CollectionProvider>(
        builder: (context, tripProv, colProv, _) {

          if (tripProv.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // If server report failed, fall back to offline summary
          if (tripProv.error != null || tripProv.report == null) {
            return _offlineSummary(colProv);
          }

          final report      = tripProv.report!;
          final hasShortfall = report.suppliers.any((s) => s.hasShortfall);

          return Column(
            children: [

              // Summary header
              Container(
                color: const Color(0xFF2E7D32),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _stat('${report.totalKg.toStringAsFixed(1)} kg',
                        'Total Collected'),
                    _stat(
                        '${report.routeDistanceKm.toStringAsFixed(1)} km',
                        'Route Distance'),
                    _stat('${report.tripDurationMinutes} min', 'Duration'),
                  ],
                ),
              ),

              // Shortfall warning banner
              if (hasShortfall)
                Container(
                  color: const Color(0xFFFFCC02),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.black87),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some suppliers had shortfalls — see flags below.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Per-supplier report tiles
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    ...report.suppliers
                        .map((s) => ReportTile(supplier: s)),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Sync button
              _syncButton(colProv),
            ],
          );
        },
      ),
    );
  }

  /// Shown when the server report cannot be loaded – uses local SQLite data.
  Widget _offlineSummary(CollectionProvider colProv) {
    final collections = colProv.collections;
    final totalKg = collections.fold<double>(
        0, (sum, c) => sum + c.clearKg + c.colouredKg);

    return Column(
      children: [
        Container(
          color: const Color(0xFF2E7D32),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('${collections.length}', 'Stops Done'),
              _stat('${totalKg.toStringAsFixed(1)} kg', 'Total (local)'),
              _stat('Offline', 'Report'),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Could not load full report from server.\nShowing local data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
        Expanded(
          child: ListView(
            children: collections
                .map(
                  (c) => ListTile(
                    leading: const Icon(Icons.recycling,
                        color: Color(0xFF2E7D32)),
                    title: Text('Supplier ID: ${c.supplierId}'),
                    subtitle: Text(
                      'Clear: ${c.clearKg} kg  '
                      'Coloured: ${c.colouredKg} kg  '
                      'Condition: ${c.condition}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _syncButton(colProv),
      ],
    );
  }

  Widget _syncButton(CollectionProvider colProv) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (colProv.syncDone)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Text(
                    'All records synced successfully!',
                    style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          if (colProv.syncFail)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: Colors.red),
                  SizedBox(width: 6),
                  Text(
                    'Sync failed. Data saved locally.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  colProv.syncing ? null : () => colProv.syncToServer(),
              icon: colProv.syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label:
                  Text(colProv.syncing ? 'Syncing...' : 'Sync to Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
