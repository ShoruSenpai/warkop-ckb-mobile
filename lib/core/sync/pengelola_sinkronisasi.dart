import 'antrean_sinkronisasi.dart';
import 'status_sinkronisasi.dart';

class SyncManager {
  SyncManager(this.queue);

  final SyncQueue queue;
  SyncStatus status = SyncStatus.idle;

  Future<void> synchronize() async {
    if (status == SyncStatus.syncing) return;

    status = SyncStatus.syncing;
    try {
      SyncTask? task;
      while ((task = queue.takeNext()) != null) {
        await task!();
      }
      status = SyncStatus.completed;
    } catch (_) {
      status = SyncStatus.failed;
      rethrow;
    }
  }
}