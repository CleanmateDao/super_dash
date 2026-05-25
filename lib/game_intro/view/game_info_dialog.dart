import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/constants/constants.dart';
import 'package:cleanmate_rush/gen/assets.gen.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GameInfoDialog extends StatelessWidget {
  const GameInfoDialog({super.key});

  static PageRoute<void> route() {
    return HeroDialogRoute(
      settings: const RouteSettings(name: RushAnalyticsScreen.gameInfo),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const ResponsiveDialogFrame(
          child: GameInfoDialog(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final linkStyle = textTheme.bodyLarge?.copyWith(
      color: tokens.primary,
      decoration: TextDecoration.underline,
      decorationColor: tokens.primary,
      fontWeight: AppFontWeights.medium,
    );
    return AppDialog(
      backgroundColor: tokens.card,
      gradient: tokens.cardGradient,
      border: Border.all(color: tokens.border),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = ResponsiveInsets.logoWidth(context) * 0.6;
              return Assets.images.gameLogo.image(width: logoWidth);
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  l10n.aboutCleanmateRush,
                  style: textTheme.titleMedium?.copyWith(
                    color: tokens.foreground,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: l10n.privacyPolicy,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrlString(Urls.privacyPolicy),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: l10n.termsOfService,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrlString(Urls.termsOfService),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
