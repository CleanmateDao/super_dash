import 'dart:async';
import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/score/score.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:cleanmate_rush/utils/utils.dart';
import 'package:cleanmate_rush/widgets/xp_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage({super.key});

  static Page<void> page() {
    return const MaterialPage(
      child: GameOverPage(),
    );
  }

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  var _isClaiming = false;
  var _hasClaimed = false;
  var _showClaimError = false;

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
            alignment:
                context.isLarge ? const Alignment(0, -.5) : Alignment.topCenter,
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
                  if (_showClaimError) ...[
                    Text(
                      l10n.scoreSubmissionErrorMessage,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: tokens.destructive,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GameElevatedButton(
                    expanded: context.isCompact,
                    label: l10n.claimAndQuitGame,
                    onPressed: _isClaiming
                        ? null
                        : () => unawaited(
                              _claimAndComplete(
                                ScoreFlowResult.backToLocations,
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),
                  GameElevatedButton.icon(
                    expanded: context.isCompact,
                    label: l10n.claimAndPlayAgain,
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 16,
                      color: tokens.primaryForeground,
                    ),
                    onPressed: _isClaiming
                        ? null
                        : () => unawaited(
                              _claimAndComplete(
                                ScoreFlowResult.playAgain,
                              ),
                            ),
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

  Future<void> _claimAndComplete(ScoreFlowResult result) async {
    setState(() {
      _isClaiming = true;
      _showClaimError = false;
    });

    final claimed = await _claimXp();
    if (!mounted) {
      return;
    }

    if (!claimed) {
      setState(() {
        _isClaiming = false;
        _showClaimError = true;
      });
      return;
    }

    final analytics = context.read<RushAnalytics>();
    switch (result) {
      case ScoreFlowResult.playAgain:
        unawaited(analytics.logPlayAgain(source: 'game_over'));
        completePlayAgainFlow(context);
      case ScoreFlowResult.backToLocations:
        unawaited(analytics.logScreenView(RushAnalyticsScreen.locations));
        completeBackToLocationsFlow(context);
      case ScoreFlowResult.dismissed:
        break;
    }
  }

  Future<bool> _claimXp() async {
    if (_hasClaimed) {
      return true;
    }

    final xp = context.read<ScoreBloc>().xp;
    if (xp <= 0) {
      _hasClaimed = true;
      return true;
    }

    final sessionRepository = context.read<UserSessionRepository>();
    final apiClient = context.read<RushApiClient>();
    final realtimeService = context.read<RushRealtimeService>();
    final analytics = context.read<RushAnalytics>();
    final session = await sessionRepository.readSession();
    if (session == null) {
      _hasClaimed = true;
      return true;
    }

    try {
      final result = await apiClient.postGameplayXp(
        token: session.token,
        amount: xp,
        runId: _newRunId(xp),
      );
      if (!mounted) {
        return false;
      }
      realtimeService.notifyXpAwarded(result);
      unawaited(analytics.logXpPosted(xp: xp));
      _hasClaimed = true;
      return true;
    } on RushApiException catch (error) {
      if (!mounted) {
        return false;
      }
      unawaited(
        analytics.logXpPostFailed(
          xp: xp,
          statusCode: error.statusCode,
        ),
      );
      if (error.statusCode == 401 || error.statusCode == 403) {
        await sessionRepository.clearSession();
      }
      return false;
    } on Exception {
      if (mounted) {
        unawaited(analytics.logXpPostFailed(xp: xp));
      }
      return false;
    }
  }

  String _newRunId(double xp) {
    final randomPart = Random().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$xp-$randomPart';
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
