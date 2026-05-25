import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/constants/constants.dart';
import 'package:cleanmate_rush/game_intro/game_intro.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AppSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AudioButton(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.cleanmateRush,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: tokens.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: tokens.primary.withValues(alpha: 0.4),
                        ),
                        children: [
                          TextSpan(
                            text: l10n.privacyPolicy,
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => launchUrlString(Urls.privacyPolicy),
                          ),
                          TextSpan(
                            text: '  |  ',
                            style: TextStyle(
                              color: tokens.mutedForeground,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextSpan(
                            text: l10n.termsOfService,
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => launchUrlString(Urls.termsOfService),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const InfoButton(),
            ],
          ),
        ),
      ),
    );
  }
}
