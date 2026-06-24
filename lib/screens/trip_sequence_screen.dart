// lib/screens/trip_sequence_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/supplier_card.dart';
import '../utils/app_routes.dart';

/// Screen 1 – Shows today's optimised route sequence.
class TripSequenceScreen extends StatefulWidget {
  const TripSequenceScreen({super.key});

  @override
  State<TripSequenceScreen> createState() => _TripSequenceScreenState();
}

class _TripSequenceScreenState extends State<TripSequenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).loadRoute();
      Provider.of<TripProvider>(context, listen: false).startTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Waste Glass Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh route',
            onPressed: () =>
                Provider.of<SupplierProvider>(context, listen: false)
                    .loadRoute(),
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {

          // Loading
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load route from server.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadRoute(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty
          if (provider.stops.isEmpty) {
            return const Center(
              child: Text('No stops scheduled for today.'),
            );
          }

          final route = provider.route!;

          return Column(
            children: [

              // Summary banner
              Container(
                color: const Color(0xFF1565C0),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statBox('${provider.stops.length}', 'Total Stops',
                        Icons.location_pin),
                    _statBox('${provider.remainingCount}', 'Remaining',
                        Icons.pending_actions),
                    _statBox(
                        '${route.totalDistanceKm.toStringAsFixed(1)} km',
                        'Total Route',
                        Icons.route),
                  ],
                ),
              ),

              // Stop list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: provider.stops.length,
                  itemBuilder: (_, i) => SupplierCard(
                    supplier: provider.stops[i],
                    index: i + 1,
                  ),
                ),
              ),

              // Go to next stop button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.remainingCount == 0
                        ? null
                        : () => Navigator.pushNamed(
                            context, AppRoutes.scanCollect),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      provider.remainingCount == 0
                          ? 'All Stops Completed'
                          : 'Go to Next Stop',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // View report button (only when all done)
              if (provider.allDone)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.tripReport),
                      icon: const Icon(Icons.summarize),
                      label: const Text('View Trip Report'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _statBox(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
