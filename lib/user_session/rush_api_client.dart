import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:leaderboard_repository/leaderboard_repository.dart';

class RushApiException implements Exception {
  const RushApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class RushLinkResult {
  const RushLinkResult({
    required this.address,
    required this.token,
  });

  final String address;
  final String token;
}

class RushProfile {
  const RushProfile({
    required this.address,
    required this.xpTotal,
    required this.weekXp,
    required this.tierMultiplier,
    required this.tierLabel,
  });

  final String address;
  final num xpTotal;
  final num weekXp;
  final num tierMultiplier;
  final String tierLabel;
}

class RushWeeklyPlacement {
  const RushWeeklyPlacement({
    required this.rank,
    required this.weekXp,
    required this.rewardPoolAmount,
  });

  final int rank;
  final num weekXp;
  final num rewardPoolAmount;
}

class RushWeeklyLeaderboardSelf {
  const RushWeeklyLeaderboardSelf({
    required this.weeksAgo,
    required this.weekStart,
    required this.weekEndExclusive,
    required this.placement,
    required this.previousWeekXp,
  });

  final int weeksAgo;
  final String weekStart;
  final String weekEndExclusive;
  final RushWeeklyPlacement? placement;
  final num previousWeekXp;
}

class RushXpAwardResult {
  const RushXpAwardResult({
    required this.applied,
    required this.delta,
    required this.xpTotal,
    required this.weekXp,
  });

  final bool applied;
  final num delta;
  final num xpTotal;
  final num weekXp;
}

class RushApiClient {
  RushApiClient({
    http.Client? httpClient,
    Uri? baseUri,
    NetworkCache? cache,
    Duration profileCacheTtl = const Duration(seconds: 30),
    Duration weeklyLeaderboardCacheTtl = const Duration(seconds: 30),
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUri = baseUri ?? Uri.https('api.cleanmatedao.com'),
        _cache = cache,
        _profileCacheTtl = profileCacheTtl,
        _weeklyLeaderboardCacheTtl = weeklyLeaderboardCacheTtl;

  final http.Client _httpClient;
  final Uri _baseUri;
  final NetworkCache? _cache;
  final Duration _profileCacheTtl;
  final Duration _weeklyLeaderboardCacheTtl;

  String get socketOrigin => '${_baseUri.scheme}://${_baseUri.host}';

  static String _tokenCacheScope(String token) =>
      token.hashCode.toRadixString(16);

  void _invalidateAuthenticatedCache(String token) {
    final scope = _tokenCacheScope(token);
    _cache?.invalidateWhere((key) => key.contains(':$scope'));
  }

  Future<RushLinkResult> verifyOtp(String otp) async {
    final response = await _httpClient.post(
      _uri('/rush/linking/verify'),
      headers: _jsonHeaders(),
      body: jsonEncode({'otp': otp}),
    );
    final data = _decodeData(response);
    final result = RushLinkResult(
      address: data.string('address'),
      token: data.string('token'),
    );
    _invalidateAuthenticatedCache(result.token);
    return result;
  }

  Future<RushWeeklyLeaderboardSelf> fetchWeeklyLeaderboardMe(
    String token, {
    int weeksAgo = 0,
    bool forceRefresh = false,
  }) async {
    final cache = _cache;
    if (cache == null) {
      return _fetchWeeklyLeaderboardMe(token, weeksAgo: weeksAgo);
    }

    final scope = _tokenCacheScope(token);
    return cache.getOrFetch(
      key: 'rush:weekly:$scope:$weeksAgo',
      ttl: _weeklyLeaderboardCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () => _fetchWeeklyLeaderboardMe(token, weeksAgo: weeksAgo),
    );
  }

  Future<RushWeeklyLeaderboardSelf> _fetchWeeklyLeaderboardMe(
    String token, {
    required int weeksAgo,
  }) async {
    final response = await _httpClient.get(
      _uri(
        '/xp/leaderboard/weekly/me',
        queryParameters: {'weeksAgo': '$weeksAgo'},
      ),
      headers: _jsonHeaders(token),
    );
    final data = _decodeData(response);
    final placementRaw = data['placement'];
    RushWeeklyPlacement? placement;
    if (placementRaw is Map<String, dynamic>) {
      placement = RushWeeklyPlacement(
        rank: placementRaw.number('rank').toInt(),
        weekXp: placementRaw.number('weekXp'),
        rewardPoolAmount: placementRaw.number('rewardPoolAmount'),
      );
    }
    return RushWeeklyLeaderboardSelf(
      weeksAgo: data.number('weeksAgo').toInt(),
      weekStart: data.string('weekStart'),
      weekEndExclusive: data.string('weekEndExclusive'),
      placement: placement,
      previousWeekXp: data.number('previousWeekXp'),
    );
  }

  Future<RushProfile> fetchProfile(
    String token, {
    bool forceRefresh = false,
  }) async {
    final cache = _cache;
    if (cache == null) {
      return _fetchProfile(token);
    }

    final scope = _tokenCacheScope(token);
    return cache.getOrFetch(
      key: 'rush:profile:$scope',
      ttl: _profileCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () => _fetchProfile(token),
    );
  }

  Future<RushProfile> _fetchProfile(String token) async {
    final response = await _httpClient.get(
      _uri('/rush/me'),
      headers: _jsonHeaders(token),
    );
    final data = _decodeData(response);
    final tier = data.object('allocationTier');
    return RushProfile(
      address: data.string('address'),
      xpTotal: data.number('xpTotal'),
      weekXp: data.number('weekXp'),
      tierMultiplier: tier.number('multiplier'),
      tierLabel: tier.string('label'),
    );
  }

  Future<RushXpAwardResult> postGameplayXp({
    required String token,
    required double amount,
    required String runId,
  }) async {
    final response = await _httpClient.post(
      _uri('/rush/xp/gameplay'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'amount': amount, 'runId': runId}),
    );
    final data = _decodeData(response);
    final result = RushXpAwardResult(
      applied: data.boolean('applied'),
      delta: data.number('delta'),
      xpTotal: data.number('xpTotal'),
      weekXp: data.number('weekXp'),
    );
    if (result.applied) {
      _invalidateAuthenticatedCache(token);
    }
    return result;
  }

  Map<String, String> _jsonHeaders([String? token]) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _baseUri.replace(
      path: path,
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _decodeData(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw RushApiException(message, statusCode: response.statusCode);
        }
      }
      throw RushApiException(
        'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const RushApiException('Unexpected API response');
    }
    return data;
  }
}

extension on Map<String, dynamic> {
  String string(String key) {
    final value = this[key];
    if (value is String) return value;
    throw RushApiException('Missing $key');
  }

  num number(String key) {
    final value = this[key];
    if (value is num) return value;
    throw RushApiException('Missing $key');
  }

  bool boolean(String key) {
    final value = this[key];
    if (value is bool) return value;
    throw RushApiException('Missing $key');
  }

  Map<String, dynamic> object(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    throw RushApiException('Missing $key');
  }
}
