import 'dart:async';

import 'package:cleanmate_rush/analytics/rush_analytics.dart';
import 'package:cleanmate_rush/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShareController {
  ShareController({
    required this.gameUrl,
    RushAnalytics? rushAnalytics,
  }) : _rushAnalytics = rushAnalytics ?? RushAnalytics.noop();

  final String gameUrl;
  final RushAnalytics _rushAnalytics;

  String _postContent(double xp) {
    final xpFormatted = formatXp(xp);
    return 'I earned $xpFormatted cleaning up trash in #CleanmateRush. '
        'Can you clean up more?';
  }

  String _twitterUrl(String content) =>
      'https://twitter.com/intent/tweet?text=$content $gameUrl';

  String facebookUrl(String content) =>
      'https://www.facebook.com/sharer.php?u=$gameUrl';

  String _encode(String content) =>
      content.replaceAll(' ', '%20').replaceAll('#', '%23');

  Future<bool> shareOnTwitter(double xp) async {
    unawaited(_rushAnalytics.logShareTwitter(xp: xp));
    final content = _postContent(xp);
    final url = _encode(_twitterUrl(content));
    return launchUrlString(url);
  }

  Future<bool> shareOnFacebook(double xp) async {
    unawaited(_rushAnalytics.logShareFacebook(xp: xp));
    final content = _postContent(xp);
    final url = _encode(facebookUrl(content));
    return launchUrlString(url);
  }
}
