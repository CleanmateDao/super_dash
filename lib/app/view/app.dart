import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:cleanmate_rush/app_lifecycle/app_lifecycle.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/map_tester/map_tester.dart';
import 'package:cleanmate_rush/settings/settings.dart';
import 'package:cleanmate_rush/share/share.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

class App extends StatelessWidget {
  const App({
    required this.audioController,
    required this.settingsController,
    required this.shareController,
    required this.authenticationRepository,
    required this.leaderboardRepository,
    this.isTesting = false,
    super.key,
  });

  final bool isTesting;
  final AudioController audioController;
  final SettingsController settingsController;
  final ShareController shareController;
  final AuthenticationRepository authenticationRepository;
  final LeaderboardRepository leaderboardRepository;

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
          RepositoryProvider<ShareController>.value(
            value: shareController,
          ),
          RepositoryProvider<AuthenticationRepository>.value(
            value: authenticationRepository..signInAnonymously(),
          ),
          RepositoryProvider<LeaderboardRepository>.value(
            value: leaderboardRepository,
          ),
          RepositoryProvider<RushApiClient>(
            create: (context) => RushApiClient(),
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
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => _RushSessionInvalidationListener(
            child: child ?? const SizedBox.shrink(),
          ),
          home: isTesting ? const MapTesterView() : const GameIntroPage(),
        ),
      ),
    );
  }
}

class _RushSessionInvalidationListener extends StatefulWidget {
  const _RushSessionInvalidationListener({required this.child});

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
    if (!mounted || session != null) {
      return;
    }
    final navigator = Navigator.maybeOf(context);
    navigator?.popUntil((route) => route.isFirst);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Cleanmate Rush was disconnected. Link again to play.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
