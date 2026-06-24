// lib/screens/scan_collect_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/collection.dart';
import '../providers/supplier_provider.dart';
import '../providers/collection_provider.dart';
import '../services/barcode_service.dart';
import '../services/api_service.dart';
import '../widgets/quantity_form.dart';
import '../utils/app_routes.dart';

/// Screen 2 – Barcode scan then quantity entry.
class ScanCollectScreen extends StatefulWidget {
  const ScanCollectScreen({super.key});

  @override
  State<ScanCollectScreen> createState() => _ScanCollectScreenState();
}

class _ScanCollectScreenState extends State<ScanCollectScreen> {
  final MobileScannerController _scannerCtrl = MobileScannerController();

  bool _scanned = false;
  bool _verified = false;
  bool _wrongBarcode = false;
  bool _submitting = false;
  String _scanMessage = 'Point camera at the supplier barcode';

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue ?? ''
        : '';
    if (raw.isEmpty) return;

    setState(() => _scanned = true);
    _scannerCtrl.stop();

    final supplierId = BarcodeService.decode(raw);
    // Use context.read safely - we are inside a callback, not build
    final currentStop =
        Provider.of<SupplierProvider>(context, listen: false).currentStop;

    if (supplierId == null || currentStop == null) {
      setState(() {
        _wrongBarcode = true;
        _scanMessage = 'Invalid barcode. Please try again.';
      });
      return;
    }

    if (supplierId != currentStop.id) {
      setState(() {
        _wrongBarcode = true;
        _scanMessage =
            'Wrong supplier! Expected: ${currentStop.name}\nScanned ID: $supplierId';
      });
      return;
    }

    setState(() {
      _verified = true;
      _wrongBarcode = false;
      _scanMessage = 'Barcode verified ✓  ${currentStop.name}';
    });
  }

  Future<void> _submitCollection(
      double clearKg, double colouredKg, String condition) async {
    final supplierProvider =
        Provider.of<SupplierProvider>(context, listen: false);
    final colProvider = Provider.of<CollectionProvider>(context, listen: false);
    final stop = supplierProvider.currentStop!;

    setState(() => _submitting = true);

    final collection = Collection(
      supplierId: stop.id,
      clearKg: clearKg,
      colouredKg: colouredKg,
      condition: condition,
      timestamp: DateTime.now(),
    );

    // 1. Save locally first (offline-first)
    await colProvider.addCollection(collection);

    // 2. Try to push to server immediately (non-blocking)
    try {
      await ApiService.submitCollection(collection);
    } catch (_) {
      // Server push failed - data is safe locally, will sync on Screen 3
    }

    // 3. Update route state
    supplierProvider.markCollected(stop.id);

    if (!mounted) return;
    setState(() => _submitting = false);

    // If all done navigate to report; otherwise go back to Screen 1
    if (supplierProvider.allDone) {
      Navigator.pushReplacementNamed(context, AppRoutes.tripReport);
    } else {
      Navigator.pop(context);
    }
  }

  void _resetScan() {
    setState(() {
      _scanned = false;
      _verified = false;
      _wrongBarcode = false;
      _scanMessage = 'Point camera at the supplier barcode';
    });
    _scannerCtrl.start();
  }

  @override
  Widget build(BuildContext context) {
    final stop = Provider.of<SupplierProvider>(context).currentStop;

    if (stop == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan & Collect')),
        body: const Center(child: Text('No current stop found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Scan & Collect'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Destination card ─────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next Destination',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(stop.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(stop.address,
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expected: ${stop.expectedClearKg} kg clear  +  '
                      '${stop.expectedColouredKg} kg coloured',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Step 1: Scanner ──────────────────────────────────
            if (!_verified) ...[
              const Text('Step 1: Scan Barcode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: MobileScanner(
                    controller: _scannerCtrl,
                    onDetect: _onDetect,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _wrongBarcode
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _wrongBarcode ? Icons.error_outline : Icons.info_outline,
                      color: _wrongBarcode ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scanMessage,
                        style: TextStyle(
                          color: _wrongBarcode ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_wrongBarcode || _scanned)
                TextButton.icon(
                  onPressed: _resetScan,
                  icon: const Icon(Icons.replay),
                  label: const Text('Scan Again'),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _verified = true;
                      _wrongBarcode = false;
                      _scanMessage = 'Barcode verified ✓ (Test Mode)';
                    });
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Skip Scan (Test Mode)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              // ── Step 2: Collection form ──────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scanMessage,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Step 2: Enter Collection Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_submitting)
                const Center(child: CircularProgressIndicator())
              else
                QuantityForm(onSubmit: _submitCollection),
            ],
          ],
        ),
      ),
    );
  }
}
