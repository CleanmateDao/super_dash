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
            unawaited(_game?.restartRun());
          case ScoreFlowResult.backToLocations:
            Navigator.of(context, rootNavigator: true).pop();
          case ScoreFlowResult.dismissed:
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
