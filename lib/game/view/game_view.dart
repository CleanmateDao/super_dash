import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/score/score.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  static PageRoute<void> route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: RushAnalyticsScreen.game),
      pageBuilder: (_, __, ___) => const Game(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: const GameView(),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  CleanmateRushGame? _game;
  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  void _showGameEndScreen(double xp) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final analytics = context.read<RushAnalytics>();
      final gameState = context.read<GameBloc>().state;
      unawaited(
        analytics.logRunCompleted(
          xp: xp,
          level: gameState.currentLevel,
          section: gameState.currentSection,
        ),
      );
      Navigator.of(context, rootNavigator: true)
          .push<ScoreFlowResult>(ScorePage.route(xp: xp))
          .then((result) {
        if (!mounted || result == null) {
          return;
        }
        switch (result) {
          case ScoreFlowResult.playAgain:
            unawaited(analytics.logPlayAgain(source: 'score_flow'));
            _restartGameAfterScoreFlow();
          case ScoreFlowResult.backToLocations:
            Navigator.of(context, rootNavigator: true).pop();
          case ScoreFlowResult.dismissed:
            break;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _lifecycleNotifier = context.read<ValueNotifier<AppLifecycleState>>()
      ..addListener(_handleLifecycleChanged);
  }

  @override
  void dispose() {
    _lifecycleNotifier?.removeListener(_handleLifecycleChanged);
    _lifecycleNotifier = null;
    _game = null;
    super.dispose();
  }

  void _restartGameAfterScoreFlow() {
    final navigator = Navigator.of(context, rootNavigator: true);
    _game = null;

    // Wait until the score route has finished popping before replacing game.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      navigator.pushReplacement(Game.route());
    });
  }

  void _handleLifecycleChanged() {
    final notifier = _lifecycleNotifier;
    final game = _game;
    if (notifier == null || game == null) {
      return;
    }

    switch (notifier.value) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Best-effort: if the app is backgrounded/closed, end the run and post
        // any earned XP.
        if (!game.hasEndedRun) {
          unawaited(game.quitRun());
        }
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        unawaited(_handleGameExit());
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            GameWidget.controlled(
              loadingBuilder: (context) => const GameBackground(),
              backgroundBuilder: (context) => const GameBackground(),
              gameFactory: () {
                final game = CleanmateRushGame(
                  gameBloc: context.read<GameBloc>(),
                  audioController: context.read<AudioController>(),
                  rushAnalytics: context.read<RushAnalytics>(),
                  onRunEnded: _showGameEndScreen,
                );
                _game = game;
                unawaited(context.read<RushAnalytics>().logGameRunStarted());
                return game;
              },
              overlayBuilderMap: {
                'tapToJump': (context, game) => const TapToJumpOverlay(),
              },
              initialActiveOverlays: const ['tapToJump'],
            ),
            Positioned(
              top: 12,
              left: ResponsiveInsets.page(context).left,
              right: ResponsiveInsets.page(context).right,
              child: const XpLabel(),
            ),
            Positioned(
              bottom: 12,
              left: ResponsiveInsets.page(context).left,
              right: ResponsiveInsets.page(context).right,
              child: const SafeArea(
                child: Center(child: AudioButton()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGameExit() async {
    final game = _game;
    if (game != null && !game.hasEndedRun) {
      await game.quitRun();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
