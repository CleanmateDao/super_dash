import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leaderboard_repository/leaderboard_repository.dart';

/// {@template leaderboard_repository}
/// Repository to access Cleanmate XP leaderboard data.
/// {@endtemplate}
class LeaderboardRepository {
  /// {@macro leaderboard_repository}
  LeaderboardRepository({
    http.Client? httpClient,
    Uri? weeklyLeaderboardUri,
  })  : _httpClient = httpClient ?? http.Client(),
        _weeklyLeaderboardUri = weeklyLeaderboardUri ??
            Uri.https(
              'api.cleanmatedao.com',
              '/xp/leaderboard/weekly',
            );

  final http.Client _httpClient;
  final Uri _weeklyLeaderboardUri;

  /// Acquires weekly [LeaderboardEntryData]s for the leaderboard screen.
  Future<List<LeaderboardEntryData>> fetchTop10Leaderboard() async {
    return fetchWeeklyLeaderboard();
  }

  /// Acquires weekly [LeaderboardEntryData]s from the Cleanmate XP API.
  Future<List<LeaderboardEntryData>> fetchWeeklyLeaderboard({
    int weeksAgo = 0,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _httpClient.get(
        _weeklyLeaderboardUri.replace(
          queryParameters: {
            'weeksAgo': '$weeksAgo',
            'page': '$page',
            'limit': '$limit',
          },
        ),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Leaderboard request failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final entries = data['entries'] as List<dynamic>;

      return entries
          .cast<Map<String, dynamic>>()
          .map(LeaderboardEntryData.fromWeeklyJson)
          .toList();
    } on LeaderboardDeserializationException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      throw FetchTop10LeaderboardException(error, stackTrace);
    }
  }
}
