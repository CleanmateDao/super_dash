/// In-memory TTL cache for HTTP-backed reads with in-flight deduplication.
class NetworkCache {
  NetworkCache();

  final _entries = <String, _CacheEntry>{};
  final _inFlight = <String, Future<Object?>>{};

  /// Returns a cached value when fresh; otherwise runs [fetch] once per key.
  Future<T> getOrFetch<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final entry = _entries[key];
      if (entry != null && !entry.isExpired) {
        return entry.value as T;
      }
    } else {
      _entries.remove(key);
    }

    final inFlight = _inFlight[key];
    if (inFlight != null) {
      return await inFlight as T;
    }

    final future = fetch().then((value) {
      _entries[key] = _CacheEntry(
        value: value,
        expiresAt: DateTime.now().add(ttl),
      );
      return value;
    }).whenComplete(() {
      _inFlight.remove(key);
    });

    _inFlight[key] = future;
    return future;
  }

  /// Removes a single cache entry.
  void invalidate(String key) {
    _entries.remove(key);
  }

  /// Removes entries whose keys satisfy [test].
  void invalidateWhere(bool Function(String key) test) {
    _entries.removeWhere((key, _) => test(key));
  }

  /// Clears all cached entries and drops in-flight bookkeeping keys only
  /// (active fetches still complete).
  void clear() {
    _entries.clear();
  }
}

class _CacheEntry {
  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  final Object? value;
  final DateTime expiresAt;

  bool get isExpired => !DateTime.now().isBefore(expiresAt);
}
