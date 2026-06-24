// lib/utils/constants.dart

class AppConstants {
  // ── Change this to your hosted Railway/Render URL when deploying ──
  static const String baseUrl = 'https://waste-glass-production.up.railway.app';

  // Collector starting GPS (Moratuwa, Sri Lanka - update to your actual start)
  static const double collectorLat = 6.8218;
  static const double collectorLng = 79.8798;

  // Status strings - must match backend exactly
  static const String statusPending = 'Pending';
  static const String statusNext = 'Next';
  static const String statusCollected = 'Collected';

  // SQLite local DB
  static const String localDbName = 'waste_glass_local.db';
  static const int localDbVersion = 1;

  // Colors
  static const int colorGreen = 0xFF2E7D32;
  static const int colorOrange = 0xFFE65100;
  static const int colorGrey = 0xFF757575;
  static const int colorRed = 0xFFB71C1C;
  static const int colorBlue = 0xFF1565C0;
}
