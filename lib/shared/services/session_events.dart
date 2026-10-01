typedef SessionExpiredCallback = void Function();

class SessionEventBus {
  static final List<SessionExpiredCallback> _listeners = [];

  static void addListener(SessionExpiredCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  static void removeListener(SessionExpiredCallback listener) {
    _listeners.remove(listener);
  }

  static void notifySessionExpired() {
    for (final listener in List<SessionExpiredCallback>.from(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }
}
