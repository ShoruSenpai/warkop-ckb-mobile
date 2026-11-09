typedef SyncTask = Future<void> Function();

class SyncQueue {
  final List<SyncTask> _tasks = [];

  int get length => _tasks.length;
  bool get isEmpty => _tasks.isEmpty;

  void enqueue(SyncTask task) {
    _tasks.add(task);
  }

  SyncTask? takeNext() {
    if (_tasks.isEmpty) return null;
    return _tasks.removeAt(0);
  }
}