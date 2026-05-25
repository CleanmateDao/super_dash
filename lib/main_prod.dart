import 'dart:async';

import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/app/app.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/bootstrap.dart';
import 'package:cleanmate_rush/firebase_options_prod.dart';
import 'package:cleanmate_rush/settings/persistence/persistence.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final rushAnalytics = RushAnalytics();
  unawaited(rushAnalytics.logAppOpened());

  final settings = SettingsController(
    persistence: LocalStorageSettingsPersistence(),
  );
  await settings.loadStateFromPersistence();

  final audio = AudioController()..attachSettings(settings);

  await audio.initialize();

  final networkCache = NetworkCache();
  final leaderboardRepository = LeaderboardRepository(cache: networkCache);

  unawaited(
    bootstrap(
      () => App(
        audioController: audio,
        settingsController: settings,
        rushAnalytics: rushAnalytics,
        leaderboardRepository: leaderboardRepository,
        networkCache: networkCache,
      ),
    ),
  );
}
