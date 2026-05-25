import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/app/app.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/bootstrap.dart';
import 'package:cleanmate_rush/firebase_options_dev.dart';
import 'package:cleanmate_rush/settings/persistence/persistence.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:cleanmate_rush/share/share.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final settings = SettingsController(
    persistence: LocalStorageSettingsPersistence(),
  );
  await settings.loadStateFromPersistence();

  final audio = AudioController()..attachSettings(settings);

  await audio.initialize();

  final share = ShareController(
    gameUrl: 'https://endless-runner-9481713-383737.web.app/',
  );

  final networkCache = NetworkCache();
  final leaderboardRepository = LeaderboardRepository(cache: networkCache);

  unawaited(
    bootstrap(
      (firebaseAuth) {
        final authenticationRepository = AuthenticationRepository(
          firebaseAuth: firebaseAuth,
        );

        return App(
          isTesting: true,
          audioController: audio,
          settingsController: settings,
          shareController: share,
          rushAnalytics: RushAnalytics.noop(),
          authenticationRepository: authenticationRepository,
          leaderboardRepository: leaderboardRepository,
          networkCache: networkCache,
        );
      },
    ),
  );
}
