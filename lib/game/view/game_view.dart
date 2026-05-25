import 'package:app_ui/app_ui.dart';
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

void _showGameEndScreen(BuildContext context, double xp) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(ScorePage.route(xp: xp));
  });
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GameWidget.controlled(
            loadingBuilder: (context) => const GameBackground(),
            backgroundBuilder: (context) => const GameBackground(),
            gameFactory: () => CleanmateRushGame(
              gameBloc: context.read<GameBloc>(),
              audioController: context.read<AudioController>(),
              onRunEnded: (xp) => _showGameEndScreen(context, xp),
            ),
            overlayBuilderMap: {
              'tapToJump': (context, game) => const TapToJumpOverlay(),
            },
            initialActiveOverlays: const ['tapToJump'],
          ),
          Positioned(
            top: 12,
            left: ResponsiveInsets.page(context).left,
            right: ResponsiveInsets.page(context).right,
            child: const Center(child: XpLabel()),
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
