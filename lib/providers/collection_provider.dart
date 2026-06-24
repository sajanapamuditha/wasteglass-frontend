import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../database/local_database.dart';
import '../services/api_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<Collection> _collections = [];
  bool _syncing  = false;
  bool _syncDone = false;
  bool _syncFail = false;

  List<Collection> get collections => _collections;
  bool get syncing  => _syncing;
  bool get syncDone => _syncDone;
  bool get syncFail => _syncFail;

  Future<void> addCollection(Collection c) async {
    final id = await LocalDatabase.insertCollection(c);
    _collections.add(Collection(
      localId:    id,
      supplierId: c.supplierId,
      clearKg:    c.clearKg,
      colouredKg: c.colouredKg,
      condition:  c.condition,
      timestamp:  c.timestamp,
    ));
    notifyListeners();
  }

  Future<void> loadLocal() async {
    _collections = await LocalDatabase.getAll();
    notifyListeners();
  }

  Future<void> syncToServer() async {
    _syncing  = true;
    _syncDone = false;
    _syncFail = false;
    notifyListeners();

    final unsynced = await LocalDatabase.getUnsynced();
    final success  = await ApiService.syncAll(unsynced);

    if (success) {
      for (final c in unsynced) {
        if (c.localId != null) await LocalDatabase.markSynced(c.localId!);
      }
      _syncDone = true;
    } else {
      _syncFail = true;
    }

    _syncing = false;
    notifyListeners();
  }
}
