import 'package:flutter/material.dart';
import '../models/trip_report.dart';

class ReportTile extends StatelessWidget {
  final ReportSupplier supplier;

  const ReportTile({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: supplier.hasShortfall ? const Color(0xFFFFF3E0) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    supplier.supplierName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (supplier.hasShortfall)
                  const Chip(
                    backgroundColor: Color(0xFFFFCC02),
                    label: Text(
                      '⚠ Shortfall',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            _row('Clear Glass',    supplier.collectedClearKg,   supplier.expectedClearKg),
            _row('Coloured Glass', supplier.collectedColouredKg, supplier.expectedColouredKg),
            const SizedBox(height: 4),
            Text('Condition: ${supplier.condition}',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double collected, double expected) {
    final ok = collected >= expected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            '${collected.toStringAsFixed(1)} / ${expected.toStringAsFixed(1)} kg',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }
}
