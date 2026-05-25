import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

void main() {
  group('NetworkCache', () {
    late NetworkCache cache;

    setUp(() {
      cache = NetworkCache();
    });

    test('returns cached value within TTL without refetching', () async {
      var fetchCount = 0;
      Future<String> fetch() async {
        fetchCount++;
        return 'value';
      }

      expect(
        await cache.getOrFetch(
          key: 'k',
          ttl: const Duration(seconds: 30),
          fetch: fetch,
        ),
        'value',
      );
      expect(
        await cache.getOrFetch(
          key: 'k',
          ttl: const Duration(seconds: 30),
          fetch: fetch,
        ),
        'value',
      );
      expect(fetchCount, 1);
    });

    test('deduplicates concurrent fetches for the same key', () async {
      var fetchCount = 0;
      Future<String> fetch() async {
        fetchCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 'value';
      }

      final results = await Future.wait([
        cache.getOrFetch(
          key: 'k',
          ttl: const Duration(seconds: 30),
          fetch: fetch,
        ),
        cache.getOrFetch(
          key: 'k',
          ttl: const Duration(seconds: 30),
          fetch: fetch,
        ),
      ]);

      expect(results, ['value', 'value']);
      expect(fetchCount, 1);
    });

    test('refetches after TTL expires', () async {
      var fetchCount = 0;
      Future<String> fetch() async {
        fetchCount++;
        return 'value-$fetchCount';
      }

      expect(
        await cache.getOrFetch(
          key: 'k',
          ttl: const Duration(milliseconds: 10),
          fetch: fetch,
        ),
        'value-1',
      );
      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(
        await cache.getOrFetch(
          key: 'k',
          ttl: const Duration(milliseconds: 10),
          fetch: fetch,
        ),
        'value-2',
      );
      expect(fetchCount, 2);
    });

    test('forceRefresh bypasses a fresh cache entry', () async {
      var fetchCount = 0;
      Future<String> fetch() async {
        fetchCount++;
        return 'value-$fetchCount';
      }

      await cache.getOrFetch(
        key: 'k',
        ttl: const Duration(seconds: 30),
        fetch: fetch,
      );
      expect(
        await cache.getOrFetch(
          key: 'k',
          ttl: const Duration(seconds: 30),
          fetch: fetch,
          forceRefresh: true,
        ),
        'value-2',
      );
      expect(fetchCount, 2);
    });

    test('invalidateWhere removes matching keys', () async {
      await cache.getOrFetch(
        key: 'rush:profile:a',
        ttl: const Duration(seconds: 30),
        fetch: () async => 1,
      );
      await cache.getOrFetch(
        key: 'leaderboard:weekly:0',
        ttl: const Duration(seconds: 30),
        fetch: () async => 2,
      );

      cache.invalidateWhere((key) => key.startsWith('rush:'));

      var fetchCount = 0;
      expect(
        await cache.getOrFetch(
          key: 'rush:profile:a',
          ttl: const Duration(seconds: 30),
          fetch: () async {
            fetchCount++;
            return 3;
          },
        ),
        3,
      );
      expect(fetchCount, 1);
      expect(
        await cache.getOrFetch(
          key: 'leaderboard:weekly:0',
          ttl: const Duration(seconds: 30),
          fetch: () async => 2,
        ),
        2,
      );
    });
  });
}
