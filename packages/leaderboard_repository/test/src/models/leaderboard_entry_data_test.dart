import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

void main() {
  group('LeaderboardEntry', () {
    const data = <String, dynamic>{
      'score': 1500,
      'playerInitials': 'ABC',
    };

    const leaderboardEntry = LeaderboardEntryData(
      score: 1500,
      playerInitials: 'ABC',
    );

    test('can be instantiated', () {
      const leaderboardEntry = LeaderboardEntryData.empty;

      expect(leaderboardEntry, isNotNull);
    });

    test('supports value equality.', () {
      const leaderboardEntry = LeaderboardEntryData.empty;
      const leaderboardEntry2 = LeaderboardEntryData.empty;

      expect(leaderboardEntry, equals(leaderboardEntry2));
    });

    test('can be converted to json', () {
      expect(leaderboardEntry.toJson(), equals(data));
    });

    test('can be obtained from json', () {
      final leaderboardEntryFrom = LeaderboardEntryData.fromJson(data);

      expect(leaderboardEntry, equals(leaderboardEntryFrom));
    });

    test('parses bannedAt from weekly json', () {
      final entry = LeaderboardEntryData.fromWeeklyJson({
        'rank': 1,
        'userId': 'user-1',
        'profileName': 'Runner',
        'walletAddress': '0xabc',
        'weekXp': 12.5,
        'previousWeekXp': 10,
        'rewardPoolAmount': 100,
        'bannedAt': '2026-01-01T00:00:00.000Z',
      });

      expect(entry.isBanned, isTrue);
      expect(entry.bannedAt, '2026-01-01T00:00:00.000Z');
    });
  });
}
