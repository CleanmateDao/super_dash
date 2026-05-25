import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics screen names for [RouteSettings.name] and manual logging.
abstract final class RushAnalyticsScreen {
  static const intro = 'intro';
  static const locations = 'locations';
  static const game = 'game';
  static const score = 'score';
  static const leaderboard = 'leaderboard';
  static const gameInfo = 'game_info';
  static const howToPlay = 'how_to_play';
  static const linkWallet = 'link_wallet';
  static const profile = 'profile';
  static const locationUnlock = 'location_unlock';
}

/// Custom GA4 event names (max 40 characters).
abstract final class RushAnalyticsEvent {
  static const appOpened = 'rush_app_opened';
  static const walletLinkOpened = 'rush_wallet_link_opened';
  static const walletLinkSuccess = 'rush_wallet_link_success';
  static const walletLinkFailed = 'rush_wallet_link_failed';
  static const walletSignupTapped = 'rush_wallet_signup_tapped';
  static const playPressed = 'rush_play_pressed';
  static const locationSelected = 'rush_location_selected';
  static const locationLockedTapped = 'rush_location_locked_tapped';
  static const gameRunStarted = 'rush_game_run_started';
  static const firstInput = 'rush_first_input';
  static const sectionCompleted = 'rush_section_completed';
  static const levelCompleted = 'rush_level_completed';
  static const runCompleted = 'rush_run_completed';
  static const xpPosted = 'rush_xp_posted';
  static const xpPostFailed = 'rush_xp_post_failed';
  static const playAgain = 'rush_play_again';
  static const leaderboardOpened = 'rush_leaderboard_opened';
  static const leaderboardRankingTapped = 'rush_leaderboard_ranking_tapped';
  static const infoOpened = 'rush_info_opened';
  static const howToPlayOpened = 'rush_how_to_play_opened';
  static const audioToggled = 'rush_audio_toggled';
  static const profileOpened = 'rush_profile_opened';
  static const logout = 'rush_logout';
  static const sessionDisconnected = 'rush_session_disconnected';
  static const shareTwitter = 'rush_share_twitter';
  static const shareFacebook = 'rush_share_facebook';
  static const externalLinkTapped = 'rush_external_link_tapped';
}

/// Logs Cleanmate Rush funnel and gameplay checkpoints to Firebase Analytics.
class RushAnalytics {
  RushAnalytics({
    FirebaseAnalytics? analytics,
    bool enabled = true,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _enabled = enabled;

  factory RushAnalytics.noop() => RushAnalytics(enabled: false);

  final FirebaseAnalytics _analytics;
  final bool _enabled;

  Future<void> logScreenView(String screenName) async {
    if (!_enabled) return;
    final name = _clip(screenName, 100);
    await _analytics.logScreenView(
      screenName: name,
      screenClass: name,
    );
  }

  Future<void> logAppOpened() => _log(RushAnalyticsEvent.appOpened);

  Future<void> logWalletLinkOpened() =>
      _log(RushAnalyticsEvent.walletLinkOpened);

  Future<void> logWalletLinkSuccess() =>
      _log(RushAnalyticsEvent.walletLinkSuccess);

  Future<void> logWalletLinkFailed({String? reason}) => _log(
        RushAnalyticsEvent.walletLinkFailed,
        {'reason': reason},
      );

  Future<void> logWalletSignupTapped() =>
      _log(RushAnalyticsEvent.walletSignupTapped);

  Future<void> logPlayPressed() => _log(RushAnalyticsEvent.playPressed);

  Future<void> logLocationSelected({
    required String locationName,
    required bool unlocked,
  }) =>
      _log(
        unlocked
            ? RushAnalyticsEvent.locationSelected
            : RushAnalyticsEvent.locationLockedTapped,
        {'location': locationName, 'unlocked': unlocked},
      );

  Future<void> logGameRunStarted() => _log(RushAnalyticsEvent.gameRunStarted);

  Future<void> logFirstInput() => _log(RushAnalyticsEvent.firstInput);

  Future<void> logSectionCompleted({
    required int sectionIndex,
    required int level,
  }) =>
      _log(
        RushAnalyticsEvent.sectionCompleted,
        {'section': sectionIndex, 'level': level},
      );

  Future<void> logLevelCompleted({required int level}) => _log(
        RushAnalyticsEvent.levelCompleted,
        {'level': level},
      );

  Future<void> logRunCompleted({
    required double xp,
    required int level,
    required int section,
  }) =>
      _log(
        RushAnalyticsEvent.runCompleted,
        {'xp': xp, 'level': level, 'section': section},
      );

  Future<void> logXpPosted({required double xp}) => _log(
        RushAnalyticsEvent.xpPosted,
        {'xp': xp},
      );

  Future<void> logXpPostFailed({required double xp, int? statusCode}) => _log(
        RushAnalyticsEvent.xpPostFailed,
        {
          'xp': xp,
          if (statusCode != null) 'status_code': statusCode,
        },
      );

  Future<void> logPlayAgain({required String source}) => _log(
        RushAnalyticsEvent.playAgain,
        {'source': source},
      );

  Future<void> logLeaderboardOpened({required String source}) => _log(
        RushAnalyticsEvent.leaderboardOpened,
        {'source': source},
      );

  Future<void> logLeaderboardRankingTapped() =>
      _log(RushAnalyticsEvent.leaderboardRankingTapped);

  Future<void> logInfoOpened() => _log(RushAnalyticsEvent.infoOpened);

  Future<void> logHowToPlayOpened() =>
      _log(RushAnalyticsEvent.howToPlayOpened);

  Future<void> logAudioToggled({required bool muted}) => _log(
        RushAnalyticsEvent.audioToggled,
        {'muted': muted},
      );

  Future<void> logProfileOpened() => _log(RushAnalyticsEvent.profileOpened);

  Future<void> logLogout() => _log(RushAnalyticsEvent.logout);

  Future<void> logSessionDisconnected() =>
      _log(RushAnalyticsEvent.sessionDisconnected);

  Future<void> logShareTwitter({required double xp}) => _log(
        RushAnalyticsEvent.shareTwitter,
        {'xp': xp},
      );

  Future<void> logShareFacebook({required double xp}) => _log(
        RushAnalyticsEvent.shareFacebook,
        {'xp': xp},
      );

  Future<void> logExternalLinkTapped({required String link}) => _log(
        RushAnalyticsEvent.externalLinkTapped,
        {'link': link},
      );

  Future<void> _log(
    String name, [
    Map<String, Object?>? params,
  ]) async {
    if (!_enabled) return;
    await _analytics.logEvent(
      name: name,
      parameters: _sanitize(params),
    );
  }

  Map<String, Object> _sanitize(Map<String, Object?>? params) {
    if (params == null || params.isEmpty) {
      return const {};
    }
    final out = <String, Object>{};
    for (final entry in params.entries) {
      final key = _clip(entry.key, 40);
      final value = entry.value;
      if (value == null) continue;
      if (value is bool) {
        out[key] = value ? 1 : 0;
      } else if (value is num) {
        out[key] = value;
      } else if (value is String) {
        out[key] = _clip(value, 100);
      }
    }
    return out;
  }
}

String _clip(String value, int maxLength) {
  if (value.length <= maxLength) {
    return value;
  }
  return value.substring(0, maxLength);
}
