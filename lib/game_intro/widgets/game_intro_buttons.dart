import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/leaderboard/leaderboard.dart';
import 'package:cleanmate_rush/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioButton extends StatelessWidget {
  const AudioButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    return ValueListenableBuilder<bool>(
      valueListenable: settingsController.muted,
      builder: (context, muted, child) => GameIconButton(
        icon: muted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
        onPressed: () {
          context.read<SettingsController>().toggleMuted();
          final muted = context.read<SettingsController>().muted.value;
          unawaited(
            context.read<RushAnalytics>().logAudioToggled(muted: muted),
          );
        },
      ),
    );
  }
}

class LeaderboardButton extends StatelessWidget {
  const LeaderboardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GameIconButton(
      icon: Icons.emoji_events_outlined,
      size: 18,
      alignment: const Alignment(-0.3, 0),
      onPressed: () {
        unawaited(
          context.read<RushAnalytics>().logLeaderboardOpened(
                source: 'toolbar',
              ),
        );
        Navigator.of(context).push(LeaderboardPage.route());
      },
    );
  }
}

class InfoButton extends StatelessWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GameIconButton(
      icon: Icons.info_outline,
      onPressed: () {
        unawaited(context.read<RushAnalytics>().logInfoOpened());
        Navigator.of(context).push(GameInfoDialog.route());
      },
    );
  }
}

class HowToPlayButton extends StatelessWidget {
  const HowToPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GameIconButton(
      icon: Icons.help_outline,
      onPressed: () {
        unawaited(context.read<RushAnalytics>().logHowToPlayOpened());
        Navigator.of(context).push(
          GameInstructionsOverlay.route(),
        );
      },
    );
  }
}
