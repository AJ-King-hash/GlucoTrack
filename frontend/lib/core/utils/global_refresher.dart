import 'dart:async';

/// Service for triggering global refresh events across the app
class GlobalRefresher {
  GlobalRefresher._();

  static final GlobalRefresher _instance = GlobalRefresher._();
  static GlobalRefresher get instance => _instance;

  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();
  final StreamController<String> _refreshWithKeyController =
      StreamController<String>.broadcast();

  /// Stream that emits when a global refresh is triggered
  Stream<void> get refreshStream => _refreshController.stream;

  /// Stream that emits refresh events with a specific key
  Stream<String> get refreshWithKeyStream => _refreshWithKeyController.stream;

  /// Trigger a global refresh event
  void triggerGlobalRefresh() {
    _refreshController.add(null);
  }

  /// Trigger a refresh event with a specific key
  /// Useful for refreshing specific sections of the app
  void triggerRefresh(String key) {
    _refreshWithKeyController.add(key);
  }

  /// Subscribe to global refresh events
  StreamSubscription<void> onRefresh(void Function() callback) {
    return _refreshController.stream.listen((_) => callback());
  }

  /// Subscribe to refresh events for a specific key
  StreamSubscription<String> onRefreshWithKey(
    String key,
    void Function() callback,
  ) {
    return _refreshWithKeyController.stream
        .where((eventKey) => eventKey == key)
        .listen((_) => callback());
  }

  /// Dispose the stream controllers
  void dispose() {
    _refreshController.close();
    _refreshWithKeyController.close();
  }
}

/// Convenience function to get the global refresher instance
GlobalRefresher get globalRefresher => GlobalRefresher.instance;
