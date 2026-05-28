import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/app_lifecycle/app_lifecycle.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

class _MockLeaderboardRepository extends Mock
    implements LeaderboardRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    AudioController? audioController,
    SettingsController? settingsController,
    LeaderboardRepository? leaderboardRepository,
    NetworkCache? networkCache,
    RushApiClient? rushApiClient,
    UserSessionRepository? userSessionRepository,
    RushRealtimeService? rushRealtimeService,
    RushAnalytics? rushAnalytics,
  }) {
    final cache = networkCache ?? NetworkCache();
    final apiClient = rushApiClient ?? RushApiClient(cache: cache);
    final sessionRepository =
        userSessionRepository ?? const UserSessionRepository();
    final realtimeService = rushRealtimeService ??
        RushRealtimeService(
          sessionRepository: sessionRepository,
          apiClient: apiClient,
        );
    return pumpWidget(
      AppLifecycleObserver(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(
                value: audioController ?? _MockAudioController(),
              ),
              RepositoryProvider.value(
                value: settingsController ?? _MockSettingsController(),
              ),
              RepositoryProvider.value(
                value: leaderboardRepository ?? _MockLeaderboardRepository(),
              ),
              RepositoryProvider.value(value: cache),
              RepositoryProvider.value(value: apiClient),
              RepositoryProvider.value(value: sessionRepository),
              RepositoryProvider.value(value: realtimeService),
              RepositoryProvider.value(
                value: rushAnalytics ?? RushAnalytics.noop(),
              ),
            ],
            child: widget,
          ),
        ),
      ),
    );
  }
}
