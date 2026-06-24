import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case 'Collected':
        bg   = const Color(0xFFE8F5E9);
        fg   = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        break;
      case 'Next':
        bg   = const Color(0xFFE3F2FD);
        fg   = const Color(0xFF1565C0);
        icon = Icons.navigate_next;
        break;
      default: // Pending
        bg   = const Color(0xFFFFF3E0);
        fg   = const Color(0xFFE65100);
        icon = Icons.schedule;
    }

    return Chip(
      backgroundColor: bg,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
