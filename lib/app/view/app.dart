import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/app_lifecycle/app_lifecycle.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

class App extends StatelessWidget {
  App({
    required this.audioController,
    required this.settingsController,
    required this.leaderboardRepository,
    required this.networkCache,
    required this.rushAnalytics,
    super.key,
  });

  final RushAnalytics rushAnalytics;
  final AudioController audioController;
  final SettingsController settingsController;
  final LeaderboardRepository leaderboardRepository;
  final NetworkCache networkCache;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AudioController>(
            create: (context) {
              final lifecycleNotifier =
                  context.read<ValueNotifier<AppLifecycleState>>();
              return audioController
                ..attachLifecycleNotifier(lifecycleNotifier);
            },
            lazy: false,
          ),
          RepositoryProvider<SettingsController>.value(
            value: settingsController,
          ),
          RepositoryProvider<NetworkCache>.value(
            value: networkCache,
          ),
          RepositoryProvider<LeaderboardRepository>.value(
            value: leaderboardRepository,
          ),
          RepositoryProvider<RushApiClient>(
            create: (context) => RushApiClient(
              cache: context.read<NetworkCache>(),
            ),
          ),
          RepositoryProvider<UserSessionRepository>.value(
            value: const UserSessionRepository(),
          ),
          RepositoryProvider<RushRealtimeService>(
            create: (context) {
              final service = RushRealtimeService(
                sessionRepository: context.read<UserSessionRepository>(),
                apiClient: context.read<RushApiClient>(),
              );
              unawaited(service.start());
              return service;
            },
          ),
          RepositoryProvider<RushAnalytics>.value(
            value: rushAnalytics,
          ),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          navigatorObservers: [
            RushAnalyticsNavigatorObserver(rushAnalytics),
          ],
          builder: (context, child) => _RushSessionInvalidationListener(
            rushAnalytics: rushAnalytics,
            navigatorKey: _navigatorKey,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const GameIntroPage(),
        ),
      ),
    );
  }
}

class _RushSessionInvalidationListener extends StatefulWidget {
  const _RushSessionInvalidationListener({
    required this.rushAnalytics,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
    required this.child,
  });

  final RushAnalytics rushAnalytics;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Widget child;

  @override
  State<_RushSessionInvalidationListener> createState() =>
      _RushSessionInvalidationListenerState();
}

class _RushSessionInvalidationListenerState
    extends State<_RushSessionInvalidationListener> {
  StreamSubscription<RushSession?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<UserSessionRepository>()
        .sessionChanges
        .listen(_handleSessionChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleSessionChanged(RushSession? session) {
    if (!mounted) {
      return;
    }
    if (session == null) {
      context.read<NetworkCache>().clear();
    } else {
      return;
    }
    unawaited(widget.rushAnalytics.logSessionDisconnected());
    widget.navigatorKey.currentState?.pushAndRemoveUntil<void>(
      PageRouteBuilder(
        settings: const RouteSettings(name: RushAnalyticsScreen.intro),
        pageBuilder: (_, __, ___) => const GameIntroPage(),
      ),
      (_) => false,
    );
    widget.scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Cleanmate Rush was disconnected. Link again to play.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
