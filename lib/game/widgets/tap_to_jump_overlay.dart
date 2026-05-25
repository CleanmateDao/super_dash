import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/l10n/l10n.dart';
import 'package:flutter/material.dart';

class TapToJumpOverlay extends StatelessWidget {
  const TapToJumpOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;

    return SafeArea(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: tokens.border),
            color: tokens.card.withValues(alpha: 0.92),
            boxShadow: tokens.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.tapToStart,
              style: textTheme.bodyMedium?.copyWith(
                color: tokens.foreground,
                fontWeight: AppFontWeights.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
