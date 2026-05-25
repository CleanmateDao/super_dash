import 'package:cleanmate_rush/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShareController {
  ShareController({required this.gameUrl});

  final String gameUrl;

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
    final content = _postContent(xp);
    final url = _encode(_twitterUrl(content));
    return launchUrlString(url);
  }

  Future<bool> shareOnFacebook(double xp) async {
    final content = _postContent(xp);
    final url = _encode(facebookUrl(content));
    return launchUrlString(url);
  }
}
