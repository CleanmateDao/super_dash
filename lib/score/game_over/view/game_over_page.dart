import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/score/score.dart';
import 'package:cleanmate_rush/utils/utils.dart';
import 'package:cleanmate_rush/widgets/xp_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameOverPage extends StatelessWidget {
  const GameOverPage({super.key});

  static Page<void> page() {
    return const MaterialPage(
      child: GameOverPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final titleColor = tokens.foreground;

    return PageWithBackground(
      background: const GameBackground(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.gameOverBg.provider(),
            fit: BoxFit.cover,
            alignment: context.isLarge
                ? const Alignment(0, -.5)
                : Alignment.topCenter,
          ),
        ),
        child: ResponsivePage(
          maxWidth: ResponsiveInsets.contentMaxWidth(context),
          scrollable: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topSpace = switch (context.screenLayout) {
                ScreenLayout.compact => 48.0,
                ScreenLayout.medium => 72.0,
                ScreenLayout.large => 96.0,
                ScreenLayout.extraLarge => 120.0,
              };

              return Column(
                children: [
                  SizedBox(height: topSpace),
                  AppSurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.gameOver,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.betterLuckNextTime,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.totalXp,
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _XpWidget(),
                  const SizedBox(height: 32),
                  GameElevatedButton(
                    expanded: context.isCompact,
                    label: l10n.backToLocations,
                    onPressed: () {
                      unawaited(
                        context.read<RushAnalytics>().logScreenView(
                              RushAnalyticsScreen.locations,
                            ),
                      );
                      completeBackToLocationsFlow(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  GameElevatedButton.icon(
                    expanded: context.isCompact,
                    label: l10n.playAgain,
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 16,
                      color: tokens.primaryForeground,
                    ),
                    onPressed: () {
                      unawaited(
                        context.read<RushAnalytics>().logPlayAgain(
                              source: 'game_over',
                            ),
                      );
                      completePlayAgainFlow(context);
                    },
                    gradient: tokens.blueGradient,
                  ),
                  const SizedBox(height: 24),
                  const BottomBar(),
                  SizedBox(height: ResponsiveInsets.pageVertical(context)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _XpWidget extends StatelessWidget {
  const _XpWidget();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final xp = context.select((ScoreBloc bloc) => bloc.xp);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: tokens.cardGradient,
        border: Border.all(color: tokens.border),
        borderRadius: AppRadii.pill,
        boxShadow: tokens.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const XpIcon(size: 24),
          const SizedBox(width: 8),
          Text(
            formatXp(xp),
            style: textTheme.bodyMedium?.copyWith(
              color: tokens.foreground,
              fontWeight: AppFontWeights.semibold,
            ),
          ),
        ],
      ),
    );
  }
}
