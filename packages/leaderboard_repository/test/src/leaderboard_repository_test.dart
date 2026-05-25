import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

void main() {
  group('LeaderboardRepository', () {
    test('can be instantiated', () {
      expect(LeaderboardRepository(), isNotNull);
    });

    test('fetchWeeklyLeaderboard parses API entries', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api.cleanmatedao.com');
        expect(request.url.path, '/xp/leaderboard/weekly');
        return http.Response(
          jsonEncode({
            'data': {
              'entries': [
                {
                  'rank': 1,
                  'userId': 'user-1',
                  'profileName': 'Runner',
                  'walletAddress': '0xabc',
                  'weekXp': 12.5,
                  'previousWeekXp': 10,
                  'rewardPoolAmount': 100,
                },
              ],
            },
          }),
          200,
        );
      });

      final repository = LeaderboardRepository(httpClient: client);
      final entries = await repository.fetchWeeklyLeaderboard();

      expect(entries, hasLength(1));
      expect(entries.first.rank, 1);
      expect(entries.first.weekXp, 12.5);
      expect(entries.first.profileName, 'Runner');
    });

    test(
      'throws FetchTop10LeaderboardException when the request fails',
      () async {
        final client = MockClient((request) async {
          return http.Response('error', 500);
        });

        final repository = LeaderboardRepository(httpClient: client);

        expect(
          () => repository.fetchWeeklyLeaderboard(),
          throwsA(isA<FetchTop10LeaderboardException>()),
        );
      },
    );
  });
}
