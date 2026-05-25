// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameIntroPageHeadline =>
      'Clean up trash across the world, avoid the bugs, and earn as you run!';

  @override
  String get gameIntroPagePlayButtonText => 'Play';

  @override
  String get gameInstructionsPageAutoRunTitle => 'Dash Auto-runs';

  @override
  String get gameInstructionsPageAutoRunDescription =>
      'Welcome to Cleanmate Rush. Your cleaner runs automatically through each location.';

  @override
  String get gameInstructionsPageTapToJumpTitle => 'Tap to Jump';

  @override
  String get gameInstructionsPageTapToJumpDescription =>
      'Tap the screen to make Dash jump.';

  @override
  String get gameInstructionsPageTapToJumpDescriptionDesktop =>
      'Press spacebar to make Dash jump.';

  @override
  String get gameInstructionsPageCollectEggsAcornsTitle => 'Collect Trash';

  @override
  String get gameInstructionsPageCollectEggsAcornsDescription =>
      'Pick up trash and recyclables in each location to earn rewards.';

  @override
  String get gameInstructionsPagePowerfulWingsTitle => 'Cleanup Boost';

  @override
  String get gameInstructionsPagePowerfulWingsDescription =>
      'Collect special cleanup boosts to power through tricky areas. While in midair, tap to do a double jump.';

  @override
  String get gameInstructionsPageLevelGatesTitle => 'Level Gates';

  @override
  String get gameInstructionsPageLevelGatesDescription =>
      'Advance through locations to face tougher cleanup challenges around the world.';

  @override
  String get gameInstructionsPageAvoidBugsTitle => 'Avoid Bugs';

  @override
  String get gameInstructionsPageAvoidBugsDescription =>
      'Bugs slow down the cleanup. Jump to dodge them and keep your run alive.';

  @override
  String get cleanmateRush => 'Cleanmate Rush';

  @override
  String get aboutCleanmateRush => 'About Cleanmate Rush';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get enter => 'Enter';

  @override
  String get initialsBlacklistedMessage => 'Keep it PG, use different initials';

  @override
  String get initialsErrorMessage => 'Please enter three initials';

  @override
  String get scoreSubmissionErrorMessage =>
      'There was an error submitting your score';

  @override
  String get shareYourScore =>
      'Share your Cleanmate Rush score and challenge your friends to clean up more!';

  @override
  String get pts => '';

  @override
  String get shareOn => 'Share on:';

  @override
  String get share => 'Share';

  @override
  String get backToLocations => 'Back to locations';

  @override
  String get gameOver => 'Game over!';

  @override
  String get betterLuckNextTime => 'Better luck next time.';

  @override
  String get totalXp => 'Total XP';

  @override
  String get submitScore => 'Submit score';

  @override
  String get playAgain => 'Play again';

  @override
  String gameScoreLabel(int points) {
    return '$points';
  }

  @override
  String get leaderboardPageLeaderboardHeadline => 'Leaderboard';

  @override
  String get leaderboardPageLeaderboardErrorText =>
      'There was an error while fetching the leaderboard.';

  @override
  String get leaderboardPageLeaderboardNoEntries => 'No entries';

  @override
  String get leaderboardPageGoBackButton => 'Go back';

  @override
  String get tapToStart => 'Tap/press Space to start';
}
