import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/user_identity/user_identity.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:cleanmate_rush/utils/utils.dart';
import 'package:cleanmate_rush/widgets/xp_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({
    required this.walletAddress,
    super.key,
  });

  static PageRoute<void> route({
    required String walletAddress,
  }) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: RushAnalyticsScreen.locations),
      pageBuilder: (_, __, ___) => LocationsPage(walletAddress: walletAddress),
    );
  }

  final String walletAddress;

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late Future<_LocationAccount?> _accountFuture;
  StreamSubscription<RushXpAwardResult>? _xpSubscription;
  _LocationAccount? _latestAccount;

  @override
  void initState() {
    super.initState();
    _accountFuture = _loadAccount();
    _xpSubscription =
        context.read<RushRealtimeService>().xpUpdates.listen(_handleXpUpdated);
  }

  @override
  void dispose() {
    _xpSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LocationAccount?>(
      future: _accountFuture,
      builder: (context, snapshot) {
        final account = snapshot.data;
        return _LocationsView(
          walletAddress: account?.walletAddress ?? widget.walletAddress,
          profileName: account?.profileName,
          weekXp: account?.weekXp ?? 0,
        );
      },
    );
  }

  Future<_LocationAccount?> _loadAccount() async {
    final sessionRepository = context.read<UserSessionRepository>();
    final apiClient = context.read<RushApiClient>();
    final session = await sessionRepository.readSession();
    if (session == null) {
      return null;
    }

    try {
      final profile = await apiClient.fetchProfile(session.token);
      final weekly = await apiClient.fetchWeeklyLeaderboardMe(session.token);
      final account = _LocationAccount(
        walletAddress: profile.address,
        weekXp: weekly.placement?.weekXp ?? 0,
      );
      _latestAccount = account;
      return account;
    } on RushApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await sessionRepository.clearSession();
      }
      return null;
    } on Exception {
      return null;
    }
  }

  void _handleXpUpdated(RushXpAwardResult update) {
    final latest = _latestAccount;
    if (!mounted || latest == null) {
      return;
    }
    final next = latest.copyWith(weekXp: update.weekXp);
    _latestAccount = next;
    setState(() {
      _accountFuture = Future.value(next);
    });
  }
}

class _LocationAccount {
  const _LocationAccount({
    required this.walletAddress,
    required this.weekXp,
    this.profileName,
  });

  final String walletAddress;
  final num weekXp;
  final String? profileName;

  _LocationAccount copyWith({num? weekXp}) {
    return _LocationAccount(
      walletAddress: walletAddress,
      weekXp: weekXp ?? this.weekXp,
      profileName: profileName,
    );
  }
}

class _LocationsView extends StatelessWidget {
  const _LocationsView({
    required this.walletAddress,
    required this.weekXp,
    this.profileName,
  });

  final String walletAddress;
  final String? profileName;
  final num weekXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.background,
      body: ResponsivePage(
        maxWidth: ResponsiveInsets.wideContentMaxWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlayerTopBar(
              walletAddress: walletAddress,
              profileName: profileName,
              weekXp: weekXp,
            ),
            const SizedBox(height: 16),
            Text(
              'Locations',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: tokens.foreground,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: ResponsiveInsets.gridCrossAxisCount(
                      context,
                    ),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        ResponsiveInsets.gridChildAspectRatio(context),
                    children: [
                      _LocationCard(
                        name: 'Antarctica',
                        requirement: LocationRequirement.none,
                        unlocked: true,
                        image: const AssetImage('assets/images/antarctica.png'),
                        onTap: () {
                          unawaited(
                            context.read<RushAnalytics>().logLocationSelected(
                                  locationName: 'Antarctica',
                                  unlocked: true,
                                ),
                          );
                          Navigator.of(context).push(Game.route());
                        },
                      ),
                      const _LocationCard(
                        name: 'Africa',
                        requirement: LocationRequirement(
                            xp: 100, tier: 4, squirrelNft: 1),
                        image: AssetImage('assets/images/africa.png'),
                      ),
                      const _LocationCard(
                        name: 'Asia',
                        requirement: LocationRequirement(
                            xp: 100, tier: 6, squirrelNft: 1),
                        image: AssetImage('assets/images/asia.png'),
                      ),
                      const _LocationCard(
                        name: 'Europe',
                        requirement: LocationRequirement(
                          xp: 120,
                          tier: 6,
                          squirrelNft: 1,
                        ),
                        image: AssetImage('assets/images/europe.png'),
                      ),
                      const _LocationCard(
                        name: 'North America',
                        requirement: LocationRequirement(
                            xp: 100, tier: 4, squirrelNft: 1),
                        image: AssetImage('assets/images/north_america.png'),
                      ),
                      const _LocationCard(
                        name: 'South America',
                        requirement: LocationRequirement(
                            xp: 150, tier: 15, squirrelNft: 1),
                        image: AssetImage('assets/images/south_america.png'),
                      ),
                      const _LocationCard(
                        name: 'Australia',
                        requirement: LocationRequirement(
                            xp: 200, tier: 10, squirrelNft: 1),
                        image: AssetImage('assets/images/australia.png'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AudioButton(),
                LeaderboardButton(),
                InfoButton(),
                HowToPlayButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  const _PlayerTopBar({
    required this.walletAddress,
    required this.weekXp,
    this.profileName,
  });

  final String walletAddress;
  final String? profileName;
  final num weekXp;

  Future<void> _showProfileSheet(BuildContext context) {
    unawaited(context.read<RushAnalytics>().logProfileOpened());
    return showResponsivePanel<void>(
      context: context,
      builder: (_) {
        return _ProfileBottomSheet(
          walletAddress: walletAddress,
          profileName: profileName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AppRadii.xlBorder,
        border: Border.all(color: tokens.border),
        boxShadow: tokens.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => unawaited(_showProfileSheet(context)),
              child: WalletAvatar(walletAddress: walletAddress),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WalletUsernameText(
                walletAddress: walletAddress,
                profileName: profileName,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: tokens.foreground,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatXp(weekXp.toDouble()),
                  style: textTheme.titleMedium?.copyWith(
                    color: tokens.foreground,
                    fontWeight: AppFontWeights.semibold,
                  ),
                ),
                const SizedBox(width: 4),
                const XpIcon(size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  const _ProfileBottomSheet({
    required this.walletAddress,
    this.profileName,
  });

  final String walletAddress;
  final String? profileName;

  Future<void> _logout(BuildContext context) async {
    unawaited(context.read<RushAnalytics>().logLogout());
    await context.read<UserSessionRepository>().clearWalletAddress();

    if (!context.mounted) return;

    unawaited(
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const GameIntroPage(),
        ),
        (_) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final isDialog =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.small.size;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.border),
        borderRadius: isDialog
            ? AppRadii.lgBorder
            : const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: tokens.cardShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              isDialog ? 24 : 28,
              24,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WalletAvatar(walletAddress: walletAddress, size: 88),
                const SizedBox(height: 16),
                WalletUsernameText(
                  walletAddress: walletAddress,
                  profileName: profileName,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: tokens.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  WalletUsernameText.formatWalletAddress(walletAddress),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedForeground,
                  ),
                ),
                const SizedBox(height: 24),
                GameElevatedButton(
                  expanded: true,
                  label: 'Logout',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tokens.destructive,
                      Color.lerp(tokens.destructive, tokens.foreground, 0.2)!,
                    ],
                  ),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.name,
    required this.requirement,
    required this.image,
    this.unlocked = false,
    this.onTap,
  });

  final String name;
  final LocationRequirement requirement;
  final ImageProvider image;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    const borderRadius = BorderRadius.all(Radius.circular(22));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: tokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: unlocked
                ? onTap
                : () {
                    unawaited(
                      context.read<RushAnalytics>().logLocationSelected(
                            locationName: name,
                            unlocked: false,
                          ),
                    );
                    unawaited(_showUnlockDetails(context));
                  },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: image,
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: unlocked ? .08 : .20),
                        Colors.black.withValues(alpha: unlocked ? .62 : .70),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: tokens.border),
                    borderRadius: borderRadius,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          unlocked
                              ? Icons.lock_open_outlined
                              : Icons.lock_outline,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: AppFontWeights.semibold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _RequirementLabel(
                        requirement: requirement,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: .86),
                          fontWeight: AppFontWeights.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showUnlockDetails(BuildContext context) {
    unawaited(
      context.read<RushAnalytics>().logScreenView(
            RushAnalyticsScreen.locationUnlock,
          ),
    );
    return showResponsivePanel<void>(
      context: context,
      builder: (_) {
        return _UnlockDetailsSheet(
          locationName: name,
          requirement: requirement,
        );
      },
    );
  }
}

class _UnlockDetailsSheet extends StatelessWidget {
  const _UnlockDetailsSheet({
    required this.locationName,
    required this.requirement,
  });

  final String locationName;
  final LocationRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final isDialog =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.small.size;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.border),
        borderRadius: isDialog
            ? AppRadii.lgBorder
            : const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: tokens.cardShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Unlock $locationName',
                  style: textTheme.titleLarge?.copyWith(
                    color: tokens.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete these requirements to clean up this continent.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedForeground,
                  ),
                ),
                const SizedBox(height: 20),
                ...requirement.unlockDetails.map(_UnlockRequirementTile.new),
                const SizedBox(height: 20),
                GameElevatedButton(
                  expanded: true,
                  label: 'Got it',
                  onPressed: Navigator.of(context).pop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockRequirementTile extends StatelessWidget {
  const _UnlockRequirementTile(this.detail);

  final UnlockRequirementDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.secondary,
          borderRadius: AppRadii.mdBorder,
          border: Border.all(color: tokens.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(detail.icon, color: tokens.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            detail.title,
                            style: textTheme.titleSmall?.copyWith(
                              color: tokens.foreground,
                            ),
                          ),
                        ),
                        if (detail.showXpIcon) ...[
                          const SizedBox(width: 4),
                          const XpIcon(size: 16),
                        ],
                      ],
                    ),
                    if (detail.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        detail.description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementLabel extends StatelessWidget {
  const _RequirementLabel({
    required this.requirement,
    required this.style,
  });

  final LocationRequirement requirement;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (requirement.isEmpty) {
      return Text('Unlocked', style: style);
    }

    final children = <Widget>[
      if (requirement.xp != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${requirement.xp}', style: style),
            const SizedBox(width: 3),
            const XpIcon(size: 14),
          ],
        ),
      if (requirement.tier != null)
        Text('Tier x${requirement.tier}', style: style),
      if (requirement.squirrelNft != null)
        Text('${requirement.squirrelNft} Squirrel NFT', style: style),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) Text('+', style: style),
          children[index],
        ],
      ],
    );
  }
}

class LocationRequirement {
  const LocationRequirement({
    this.xp,
    this.tier,
    this.squirrelNft,
  });

  final int? xp;
  final int? tier;
  final int? squirrelNft;

  static const none = LocationRequirement();

  bool get isEmpty => xp == null && tier == null && squirrelNft == null;

  List<UnlockRequirementDetail> get unlockDetails {
    return [
      if (xp != null)
        UnlockRequirementDetail(
          icon: Icons.bolt_outlined,
          title: 'Earn at least $xp',
          showXpIcon: true,
          description: 'Collect trash and recyclables in unlocked locations '
              'to build up your Cleanmate rewards.',
        ),
      if (tier != null)
        UnlockRequirementDetail(
          icon: Icons.how_to_vote_outlined,
          title: 'Reach Tier x$tier',
          description: 'Participate in VeBetterDAO governance and keep '
              'contributing to improve your Cleanmate tier.',
        ),
      if (squirrelNft != null)
        UnlockRequirementDetail(
          icon: Icons.pets_outlined,
          title: 'Mint $squirrelNft Squirrel NFT',
          description: 'Mint a Squirrel NFT on Cleanmate to prove you are '
              'ready for this cleanup route.',
        ),
    ];
  }
}

class UnlockRequirementDetail {
  const UnlockRequirementDetail({
    required this.icon,
    required this.title,
    required this.description,
    this.showXpIcon = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showXpIcon;
}
