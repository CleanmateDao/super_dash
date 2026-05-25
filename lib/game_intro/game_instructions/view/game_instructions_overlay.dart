import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameInstruction extends Equatable {
  const GameInstruction({
    required this.title,
    required this.description,
    required this.assetPath,
  });

  final String title;
  final String description;
  final String assetPath;

  @override
  List<Object> get props => [title, description, assetPath];
}

class GameInstructionsOverlay extends StatelessWidget {
  const GameInstructionsOverlay({super.key});

  static PageRoute<void> route() {
    return HeroDialogRoute(
      settings: const RouteSettings(name: RushAnalyticsScreen.howToPlay),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const ResponsiveDialogFrame(
          child: GameInstructionsOverlay(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameInstructionsCubit(),
      child: const GameInstructionsOverlayView(),
    );
  }
}

class GameInstructionsOverlayView extends StatefulWidget {
  const GameInstructionsOverlayView({super.key});

  @override
  State<GameInstructionsOverlayView> createState() =>
      _GameInstructionsOverlayViewState();
}

class _GameInstructionsOverlayViewState
    extends State<GameInstructionsOverlayView> {
  late final PageController pageController;

  List<GameInstruction> _instructions(BuildContext context) {
    final l10n = context.l10n;
    return [
      GameInstruction(
        title: l10n.gameInstructionsPageAutoRunTitle,
        description: l10n.gameInstructionsPageAutoRunDescription,
        assetPath: Assets.images.autoRunInstruction.path,
      ),
      if (context.isLarge)
        GameInstruction(
          title: l10n.gameInstructionsPageTapToJumpTitle,
          description: l10n.gameInstructionsPageTapToJumpDescriptionDesktop,
          assetPath: Assets.images.tapToJumpSpacebar.path,
        )
      else
        GameInstruction(
          title: l10n.gameInstructionsPageTapToJumpTitle,
          description: l10n.gameInstructionsPageTapToJumpDescription,
          assetPath: Assets.images.tapToJumpInstruction.path,
        ),
      GameInstruction(
        title: l10n.gameInstructionsPageCollectEggsAcornsTitle,
        description: l10n.gameInstructionsPageCollectEggsAcornsDescription,
        assetPath: Assets.images.collectEggsAcornsInstruction.path,
      ),
      GameInstruction(
        title: l10n.gameInstructionsPagePowerfulWingsTitle,
        description: l10n.gameInstructionsPagePowerfulWingsDescription,
        assetPath: Assets.images.powerfulWingsInstruction.path,
      ),
      GameInstruction(
        title: l10n.gameInstructionsPageLevelGatesTitle,
        description: l10n.gameInstructionsPageLevelGatesDescription,
        assetPath: Assets.images.portalInstruction.path,
      ),
      GameInstruction(
        title: l10n.gameInstructionsPageAvoidBugsTitle,
        description: l10n.gameInstructionsPageAvoidBugsDescription,
        assetPath: Assets.images.avoidBugsInstruction.path,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewport = ResponsiveInsets.instructionsViewportSize(context);

    return AppDialog(
      imageProvider: Assets.images.instructionsBackground.provider(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: context.read<GameInstructionsCubit>().updateStep,
              itemCount: _instructions(context).length,
              itemBuilder: (context, index) {
                final instruction = _instructions(context).elementAt(index);
                return _CardContent(
                  title: instruction.title,
                  description: instruction.description,
                  assetPath: instruction.assetPath,
                  pageController: pageController,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GameInstructionNavigationControls(
            pageController: pageController,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.pageController,
  });

  final String assetPath;
  final String title;
  final String description;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    return Column(
      children: [
        _CardImage(assetPath: assetPath),
        const SizedBox(height: 24),
        AppSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tokens.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.mutedForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final imageSize = switch (context.screenLayout) {
      ScreenLayout.compact => 180.0,
      ScreenLayout.medium => 200.0,
      _ => 224.0,
    };

    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: TraslucentBackground(
        border: Border.all(
          color: tokens.border,
        ),
        gradient: [
          tokens.muted,
          tokens.secondary,
          tokens.card,
          tokens.card.withValues(alpha: 0.38),
        ],
        child: Positioned.fill(
          child: Image.asset(
            assetPath,
            width: 190,
            height: 190,
          ),
        ),
      ),
    );
  }
}
