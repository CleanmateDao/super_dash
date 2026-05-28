import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/app/app.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

class _MockLeaderboardRepository extends Mock
    implements LeaderboardRepository {}

void main() {
  group('App', () {
    late AudioController audioController;
    late SettingsController settingsController;
    late LeaderboardRepository leaderboardRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      audioController = _MockAudioController();
      settingsController = _MockSettingsController();
      leaderboardRepository = _MockLeaderboardRepository();

      when(() => settingsController.muted).thenReturn(ValueNotifier(true));
    });

    testWidgets('renders GameIntroPage', (tester) async {
      await tester.pumpWidget(
        App(
          audioController: audioController,
          settingsController: settingsController,
          leaderboardRepository: leaderboardRepository,
          networkCache: NetworkCache(),
          rushAnalytics: RushAnalytics.noop(),
        ),
      );
      expect(find.byType(GameIntroPage), findsOneWidget);
    });

    testWidgets('returns to intro when account linking disconnects', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'cleanmate_wallet_address': '0x123',
        'cleanmate_rush_token': 'token',
      });
      await tester.pumpWidget(
        App(
          audioController: audioController,
          settingsController: settingsController,
          leaderboardRepository: leaderboardRepository,
          networkCache: NetworkCache(),
          rushAnalytics: RushAnalytics.noop(),
        ),
      );
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(GameIntroPage))).push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Locations')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Locations'), findsOneWidget);

      await const UserSessionRepository().clearSession();
      await tester.pumpAndSettle();

      expect(find.text('Locations'), findsNothing);
      expect(find.byType(GameIntroPage), findsOneWidget);
      expect(
        find.text('Cleanmate Rush was disconnected. Link again to play.'),
        findsOneWidget,
      );
    });
  });
}
