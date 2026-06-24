import 'package:flutter/material.dart';
import '../models/supplier.dart';
import 'status_chip.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final int      index;

  const SupplierCard({super.key, required this.supplier, required this.index});

  @override
  Widget build(BuildContext context) {
    final isNext      = supplier.status == 'Next';
    final isCollected = supplier.status == 'Collected';

    return Card(
      elevation: isNext ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isNext
            ? const BorderSide(color: Color(0xFF1565C0), width: 2)
            : BorderSide.none,
      ),
      child: Opacity(
        opacity: isCollected ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Stop number circle
              CircleAvatar(
                radius: 20,
                backgroundColor: isCollected
                    ? Colors.grey.shade300
                    : isNext
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE3F2FD),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Supplier info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      supplier.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expected: ${supplier.expectedClearKg + supplier.expectedColouredKg} kg  •  '
                      '${supplier.distanceFromPrev.toStringAsFixed(1)} km from prev',
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              StatusChip(status: supplier.status),
            ],
          ),
        ),
      ),
    );
  }
}
