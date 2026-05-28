import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:cleanmate_rush/score/score.dart';
import 'package:cleanmate_rush/user_identity/user_identity.dart';
import 'package:cleanmate_rush/widgets/b3tr_icon.dart';
import 'package:cleanmate_rush/widgets/xp_icon.dart';
import 'package:flame/cache.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

enum LeaderboardStep { gameIntro, gameScore }

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({
    this.step = LeaderboardStep.gameIntro,
    super.key,
  });

  static Page<void> page([
    LeaderboardStep step = LeaderboardStep.gameScore,
  ]) {
    return MaterialPage(
      child: LeaderboardPage(step: step),
    );
  }

  static PageRoute<void> route([
    LeaderboardStep step = LeaderboardStep.gameIntro,
  ]) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: RushAnalyticsScreen.leaderboard),
      pageBuilder: (_, __, ___) => LeaderboardPage(step: step),
    );
  }

  final LeaderboardStep step;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc(
        leaderboardRepository: context.read<LeaderboardRepository>(),
      )..add(const LeaderboardTop10Requested()),
      child: LeaderboardView(step: step),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({
    required this.step,
    super.key,
  });

  final LeaderboardStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.appTheme;
    final contentMinHeight = (MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).vertical -
            ResponsiveInsets.pageVertical(context) * 2)
        .clamp(0, double.infinity)
        .toDouble();
    return PageWithBackground(
      background: const GameBackground(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.leaderboardBg.provider(),
            fit: BoxFit.fill,
          ),
        ),
        child: ResponsivePage(
          scrollable: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentMinHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: switch (context.screenLayout) {
                    ScreenLayout.compact => 72,
                    ScreenLayout.medium => 96,
                    _ => MediaQuery.sizeOf(context).height * 0.16,
                  },
                ),
                const Leaderboard(),
                const SizedBox(height: 20),
                Align(
                  child: switch (step) {
                    LeaderboardStep.gameIntro => GameElevatedButton(
                        label: l10n.leaderboardPageGoBackButton,
                        onPressed: Navigator.of(context).pop,
                        gradient: tokens.blueGradient,
                      ),
                    LeaderboardStep.gameScore => GameElevatedButton.icon(
                        label: l10n.playAgain,
                        icon: Icon(
                          Icons.refresh_outlined,
                          size: 16,
                          color: tokens.primaryForeground,
                        ),
                        onPressed: () {
                          unawaited(
                            context.read<RushAnalytics>().logPlayAgain(
                                  source: 'leaderboard',
                                ),
                          );
                          completePlayAgainFlow(context);
                        },
                        gradient: tokens.blueGradient,
                      ),
                  },
                ),
                SizedBox(
                  height: ResponsiveInsets.pageVertical(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final panelSize = ResponsiveInsets.leaderboardPanelSize(context);

    return Align(
      child: Container(
        width: panelSize.width,
        height: panelSize.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: AppRadii.xlBorder,
          gradient: tokens.cardGradient,
          border: Border.all(color: tokens.border),
          boxShadow: tokens.cardShadow,
        ),
        child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) => switch (state) {
            LeaderboardInitial() => const SizedBox.shrink(),
            LeaderboardLoading() =>
              const Center(child: LeaderboardLoadingWidget()),
            LeaderboardError() => const Center(child: LeaderboardErrorWidget()),
            LeaderboardLoaded(entries: final entries) =>
              LeaderboardContent(entries: entries),
          },
        ),
      ),
    );
  }
}

@visibleForTesting
class LeaderboardErrorWidget extends StatelessWidget {
  const LeaderboardErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 64,
          child: SpriteAnimationWidget.asset(
            images: Images(prefix: ''),
            path: Assets.map.anim.spritesheetDashDeathFaintPng.path,
            data: SpriteAnimationData.sequenced(
              amount: 16,
              stepTime: 0.042,
              textureSize: Vector2.all(64), // Game's tile size.
              amountPerRow: 8,
              loop: false,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.leaderboardPageLeaderboardErrorText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appTheme.mutedForeground,
              ),
        ),
      ],
    );
  }
}

@visibleForTesting
class LeaderboardLoadingWidget extends StatelessWidget {
  const LeaderboardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 64,
      child: SpriteAnimationWidget.asset(
        images: Images(prefix: ''),
        path: Assets.map.anim.spritesheetDashRunPng.path,
        data: SpriteAnimationData.sequenced(
          amount: 16,
          stepTime: 0.042,
          textureSize: Vector2.all(64), // Game's tile size.
          amountPerRow: 8,
        ),
      ),
    );
  }
}

@visibleForTesting
class LeaderboardContent extends StatelessWidget {
  const LeaderboardContent({
    required this.entries,
    super.key,
  });

  final List<LeaderboardEntryData> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LeaderboardPeriodHeader(),
              const SizedBox(height: 18),
              if (entries.isEmpty)
                Center(child: Text(l10n.leaderboardPageLeaderboardNoEntries))
              else ...[
                Text(
                  'Showing ${entries.length} ranked',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RANKINGS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tokens.mutedForeground,
                      fontWeight: AppFontWeights.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: tokens.border, height: 1),
                Flexible(
                  child: _LeaderboardEntries(entries: entries),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.8],
                  colors: [
                    Colors.transparent,
                    tokens.card,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardPeriodHeader extends StatelessWidget {
  const _LeaderboardPeriodHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final weeksAgo = context.select(
      (LeaderboardBloc bloc) => bloc.state.weeksAgo,
    );
    final isLoading = context.select(
      (LeaderboardBloc bloc) => bloc.state is LeaderboardLoading,
    );
    final canGoToPreviousWeek = weeksAgo > 0 && !isLoading;
    final canGoToOlderWeek = weeksAgo < leaderboardMaxWeeksAgo && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AppRadii.lgBorder,
        border: Border.all(color: tokens.border),
        boxShadow: tokens.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            _PeriodButton(
              icon: Icons.chevron_left_outlined,
              onPressed: canGoToPreviousWeek
                  ? () => context
                      .read<LeaderboardBloc>()
                      .add(const LeaderboardPreviousWeekRequested())
                  : null,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatLeaderboardWeekLabel(weeksAgo),
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Weeks are UTC',
                    style: textTheme.bodySmall?.copyWith(
                      color: tokens.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            _PeriodButton(
              icon: Icons.chevron_right_outlined,
              onPressed: canGoToOlderWeek
                  ? () => context
                      .read<LeaderboardBloc>()
                      .add(const LeaderboardNextWeekRequested())
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GameIconButton(
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class _LeaderboardEntries extends StatelessWidget {
  const _LeaderboardEntries({required this.entries});

  final List<LeaderboardEntryData> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final tokens = context.appTheme;
    return ListView.separated(
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) {
        return Divider(color: tokens.border, height: 1);
      },
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries.elementAt(index);
        final walletAddress = entry.walletAddress;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${entry.rank ?? index + 1}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
              WalletAvatar(
                walletAddress: walletAddress ?? entry.playerInitials,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LeaderboardEntryName(entry: entry),
              ),
              const SizedBox(width: 8),
              _LeaderboardEntryScore(entry: entry),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardEntryName extends StatelessWidget {
  const _LeaderboardEntryName({required this.entry});

  final LeaderboardEntryData entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final walletAddress = entry.walletAddress;
    final nameStyle = textTheme.bodyMedium?.copyWith(
      fontWeight: AppFontWeights.medium,
    );

    return Row(
      children: [
        Flexible(
          child: walletAddress == null
              ? Text(
                  entry.playerInitials,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                )
              : WalletUsernameText(
                  walletAddress: walletAddress,
                  profileName: entry.profileName,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                ),
        ),
        if (entry.isBanned) ...[
          const SizedBox(width: 6),
          const BanBadge(),
        ],
      ],
    );
  }
}

@visibleForTesting
class BanBadge extends StatelessWidget {
  const BanBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: 'Banned account',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.destructive.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tokens.destructive),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Text(
            'BAN',
            style: textTheme.labelSmall?.copyWith(
              color: tokens.destructive,
              fontWeight: AppFontWeights.bold,
              fontSize: 9,
              height: 1,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _bannedScoreTextStyle(
  TextStyle base,
  AppThemeTokens tokens, {
  Color? color,
}) {
  final resolvedColor = color ?? base.color;
  return base.copyWith(
    color: resolvedColor?.withValues(alpha: 0.75),
    decoration: TextDecoration.lineThrough,
    decorationColor: tokens.destructive,
    decorationThickness: 2,
  );
}

class _LeaderboardEntryScore extends StatelessWidget {
  const _LeaderboardEntryScore({required this.entry});

  final LeaderboardEntryData entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final xpDelta = entry.weekXp - entry.previousWeekXp;
    final rewardPoolAmount = entry.rewardPoolAmount;
    final banned = entry.isBanned;
    final xpTextStyle = banned
        ? _bannedScoreTextStyle(
            textTheme.bodyMedium!.copyWith(fontWeight: AppFontWeights.bold),
            tokens,
          )
        : textTheme.bodyMedium?.copyWith(
            fontWeight: AppFontWeights.bold,
          );
    final rewardTextStyle = banned
        ? _bannedScoreTextStyle(
            textTheme.bodySmall!.copyWith(color: tokens.mutedForeground),
            tokens,
            color: tokens.mutedForeground,
          )
        : textTheme.bodySmall?.copyWith(
            color: tokens.mutedForeground,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Opacity(
          opacity: banned ? 0.75 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                xpDelta >= 0
                    ? Icons.trending_up_outlined
                    : Icons.trending_down_outlined,
                color: xpDelta >= 0 ? tokens.success : tokens.destructive,
                size: 15,
              ),
              const SizedBox(width: 4),
              Text(
                entry.weekXp.toStringAsFixed(2),
                style: xpTextStyle,
              ),
              const SizedBox(width: 3),
              const XpIcon(size: 16),
            ],
          ),
        ),
        if (rewardPoolAmount != null && rewardPoolAmount > 0) ...[
          const SizedBox(height: 2),
          Opacity(
            opacity: banned ? 0.75 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${rewardPoolAmount.toStringAsFixed(0)}',
                  style: rewardTextStyle,
                ),
                const SizedBox(width: 4),
                const B3trIcon(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
