import '../models/member_store.dart';

class SyncService {

  static Future<void>
  syncAll() async {

    isSyncing = true;

    print("Sync started");

    await Future.delayed(
      const Duration(seconds: 1),
    );

    print("Sync completed");

    lastSyncTime = DateTime.now();

    isSyncing = false;
  }

  static bool isSyncing = false;

  static DateTime?
    lastSyncTime;
}