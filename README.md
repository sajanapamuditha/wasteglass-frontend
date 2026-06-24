# Waste Glass Collection App — Flutter Frontend

## ⚡ Quick Setup (Fix Errors in VS Code)

The errors you see in VS Code ("package:provider doesn't exist", "package:sqflite doesn't exist" etc.)
are caused by **missing packages**. Run this ONE command to fix all of them:

```bash
cd wasteglass
flutter pub get
```

After `flutter pub get` finishes, **all red errors disappear automatically**.

---

## Project Structure

```
wasteglass/
├── lib/
│   ├── main.dart                      ← App entry point
│   ├── models/
│   │   ├── supplier.dart              ← Supplier data model
│   │   ├── collection.dart            ← Collection record model
│   │   ├── route_model.dart           ← Route from backend
│   │   └── trip_report.dart           ← Report from backend
│   ├── providers/
│   │   ├── supplier_provider.dart     ← Route & stop state
│   │   ├── collection_provider.dart   ← Collection & sync state
│   │   └── trip_provider.dart         ← Trip timing & report
│   ├── screens/
│   │   ├── trip_sequence_screen.dart  ← Screen 1: Route list
│   │   ├── scan_collect_screen.dart   ← Screen 2: Scan & collect
│   │   └── trip_report_screen.dart    ← Screen 3: Summary & sync
│   ├── services/
│   │   ├── api_service.dart           ← All HTTP calls to .NET backend
│   │   ├── barcode_service.dart       ← Barcode decode helper
│   │   ├── database_service.dart      ← Database wrapper
│   │   └── route_service.dart         ← Route helper
│   ├── database/
│   │   └── local_database.dart        ← SQLite offline storage
│   ├── widgets/
│   │   ├── supplier_card.dart         ← Stop list card
│   │   ├── status_chip.dart           ← Pending/Next/Collected badge
│   │   ├── quantity_form.dart         ← Collection entry form
│   │   └── report_tile.dart           ← Per-supplier report row
│   └── utils/
│       ├── constants.dart             ← API URL & config
│       ├── app_routes.dart            ← Route names & map
│       └── validators.dart            ← Form validators
└── pubspec.yaml
```

## Step-by-Step Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Set your backend URL
Open `lib/utils/constants.dart` and change:
```dart
static const String baseUrl = 'https://YOUR_BACKEND_URL_HERE';
```
To your actual deployed .NET backend URL, e.g.:
```dart
static const String baseUrl = 'https://waste-glass-api.railway.app';
```

For local testing (Android emulator):
```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

### 3. Android permissions
The `android/app/src/main/AndroidManifest.xml` needs camera permission for barcode scanning.
Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 4. Run the app
```bash
flutter run
```

### 5. Build APK
```bash
flutter build apk --release
```
APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## How the App Works

| Screen | What happens |
|--------|-------------|
| **Screen 1** | App calls `GET /api/route` → backend runs Dijkstra → returns sorted stops |
| **Screen 2** | Collector scans barcode → app verifies supplier ID → unlocks form → saves locally + pushes to backend |
| **Screen 3** | Shows totals, shortfall warnings → "Sync to Server" pushes all unsynced local records |

## Barcode Format
Each barcode encodes the **supplier ID as a plain number** (e.g. `1`, `2`, `3`).
Generate test barcodes at: https://barcode.tec-it.com (use Code 128 format)
