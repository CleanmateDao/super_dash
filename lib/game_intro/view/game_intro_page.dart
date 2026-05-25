import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:cleanmate_rush/locations/locations.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GameIntroPage extends StatefulWidget {
  const GameIntroPage({super.key});

  @override
  State<GameIntroPage> createState() => _GameIntroPageState();
}

class _GameIntroPageState extends State<GameIntroPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(Assets.images.gameBackground.provider(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: context.useDesktopVisuals
                ? Assets.images.introBackgroundDesktop.provider()
                : Assets.images.introBackgroundMobile.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: const _IntroPage(),
      ),
    );
  }
}

class _IntroPage extends StatefulWidget {
  const _IntroPage();

  @override
  State<_IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<_IntroPage> {
  late Future<String?> _walletAddress;
  bool? _showingLinkedScreen;
  StreamSubscription<RushSession?>? _sessionSubscription;
  var _hadLinkedSession = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<RushAnalytics>().logScreenView(RushAnalyticsScreen.intro),
    );
    final sessionRepository = context.read<UserSessionRepository>();
    _walletAddress = sessionRepository.readWalletAddress();
    unawaited(_loadInitialLinkedState(sessionRepository));
    _sessionSubscription =
        sessionRepository.sessionChanges.listen(_handleSessionChanged);
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialLinkedState(
    UserSessionRepository sessionRepository,
  ) async {
    final session = await sessionRepository.readSession();
    if (mounted) {
      _hadLinkedSession = session != null;
    }
  }

  void _handleSessionChanged(RushSession? session) {
    if (!mounted) {
      return;
    }

    if (session != null) {
      _hadLinkedSession = true;
      _refreshWalletAddress();
      return;
    }

    if (!_hadLinkedSession) {
      return;
    }

    _hadLinkedSession = false;
    setState(() {
      _walletAddress = Future<String?>.value();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final isIntroVisible = ModalRoute.of(context)?.isCurrent ?? false;
      if (isIntroVisible) {
        unawaited(_onLinkPressed());
      }
    });
  }

  void _refreshWalletAddress() {
    setState(() {
      _walletAddress =
          context.read<UserSessionRepository>().readWalletAddress();
    });
  }

  Future<void> _onLinkPressed() async {
    final analytics = context.read<RushAnalytics>();
    unawaited(analytics.logWalletLinkOpened());
    final linked = await showResponsivePanel<bool>(
      context: context,
      builder: (context) => const _LinkWalletSheet(),
    );

    if ((linked ?? false) && mounted) {
      unawaited(analytics.logWalletLinkSuccess());
      _refreshWalletAddress();
    }
  }

  void _onPlayPressed(String walletAddress) {
    unawaited(context.read<RushAnalytics>().logPlayPressed());
    Navigator.of(context)
        .push(LocationsPage.route(walletAddress: walletAddress));
  }

  void _syncIntroAudio({required bool hasLinkedWallet}) {
    if (_showingLinkedScreen == hasLinkedWallet) {
      return;
    }

    _showingLinkedScreen = hasLinkedWallet;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final audioController = context.read<AudioController>();
      if (hasLinkedWallet) {
        audioController.startMusic();
      } else {
        audioController.stopMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    return FutureBuilder<String?>(
      future: _walletAddress,
      builder: (context, snapshot) {
        final walletAddress = snapshot.data;
        final hasLinkedWallet =
            walletAddress != null && walletAddress.trim().isNotEmpty;
        _syncIntroAudio(hasLinkedWallet: hasLinkedWallet);

        return ResponsivePage(
          maxWidth: ResponsiveInsets.contentMaxWidth(context),
          child: Column(
            children: [
              const Spacer(),
              Assets.images.gameLogo.image(
                width: ResponsiveInsets.logoWidth(context),
              ),
                const Spacer(flex: 4),
                AppSurfaceCard(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameElevatedButton(
                        expanded: true,
                        label: hasLinkedWallet
                            ? l10n.gameIntroPagePlayButtonText
                            : 'Link',
                        onPressed:
                            snapshot.connectionState == ConnectionState.waiting
                                ? null
                                : hasLinkedWallet
                                    ? () => _onPlayPressed(walletAddress)
                                    : _onLinkPressed,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasLinkedWallet
                            ? l10n.gameIntroPageHeadline
                            : 'Connect your Cleanmate account to play',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (hasLinkedWallet) ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AudioButton(),
                      LeaderboardButton(),
                      InfoButton(),
                      HowToPlayButton(),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _LinkWalletSheet extends StatefulWidget {
  const _LinkWalletSheet();

  @override
  State<_LinkWalletSheet> createState() => _LinkWalletSheetState();
}

class _LinkWalletSheetState extends State<_LinkWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  var _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<RushAnalytics>().logScreenView(RushAnalyticsScreen.linkWallet),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final apiClient = context.read<RushApiClient>();
      final sessionRepository = context.read<UserSessionRepository>();
      final result = await apiClient.verifyOtp(_otpController.text.trim());
      await sessionRepository.saveRushSession(
        RushSession(walletAddress: result.address, token: result.token),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Exception catch (error) {
      if (mounted) {
        final message = error is RushApiException
            ? error.message
            : 'Unable to link Rush. Please try again.';
        unawaited(
          context.read<RushAnalytics>().logWalletLinkFailed(reason: message),
        );
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      }
    }
  }

  Future<void> _openCleanmateApp() {
    unawaited(context.read<RushAnalytics>().logWalletSignupTapped());
    unawaited(
      context.read<RushAnalytics>().logExternalLinkTapped(
            link: 'cleanmate_app',
          ),
    );
    return launchUrl(Uri.parse('http://app.cleanmatedao.com/'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final isDialog = MediaQuery.sizeOf(context).width >=
        AppBreakpoints.small.size;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.border),
          borderRadius: isDialog
              ? AppRadii.lgBorder
              : const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: tokens.cardShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Link Cleanmate account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tokens.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to your Cleanmate account games and generate a '
                    'Cleanmate Rush OTP.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lgBorder,
                      border: Border.all(color: tokens.primary.withValues(alpha: 0.25)),
                      color: tokens.primary.withValues(alpha: 0.05),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _otpController,
                        style: TextStyle(color: tokens.foreground),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          labelText: '6-digit OTP',
                          labelStyle: TextStyle(color: tokens.mutedForeground),
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          return (value ?? '').length == 6
                              ? null
                              : 'Enter the 6-digit OTP';
                        },
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.destructive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  GameElevatedButton(
                    expanded: true,
                    label: _isSubmitting ? 'Linking...' : 'Continue',
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'or',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _openCleanmateApp,
                    child: const Text(
                      "Don't have a Cleanmate account? Click here to sign up.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

