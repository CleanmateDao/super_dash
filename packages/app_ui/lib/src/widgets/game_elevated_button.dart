import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

/// {@template game_button}
/// Primary action button aligned with the Cleanmate React `Button` default
/// variant (`gradient-primary`, `text-sm`, `font-medium`, `shadow-block-primary`).
/// {@endtemplate}
class GameElevatedButton extends StatelessWidget {
  /// {@macro game_button}
  GameElevatedButton({
    required String label,
    VoidCallback? onPressed,
    this.gradient,
    this.expanded = false,
    super.key,
  }) : _child = FilledButton(
          onPressed: onPressed,
          child: Text(label),
        );

  /// {@macro game_button}
  GameElevatedButton.icon({
    required String label,
    required Icon icon,
    VoidCallback? onPressed,
    this.gradient,
    this.expanded = false,
    super.key,
  }) : _child = FilledButton.icon(
          icon: icon,
          label: Text(label),
          onPressed: onPressed,
        );

  final Widget _child;

  /// The gradient to use for the background (`gradient-primary` by default).
  final Gradient? gradient;

  /// When true, expands to the max width of the parent (React `w-full`).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.appTheme;
    final resolvedGradient = gradient ?? tokens.primaryGradient;
    final labelColor = tokens.labelColorForGradient(resolvedGradient);

    return Container(
      width: expanded ? double.infinity : null,
      constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
      decoration: BoxDecoration(
        gradient: resolvedGradient,
        borderRadius: AppRadii.buttonBorder,
        boxShadow: tokens.blockShadowForGradient(resolvedGradient),
      ),
      child: Theme(
        data: theme.copyWith(
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: labelColor,
              disabledForegroundColor: labelColor.withValues(alpha: 0.5),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.buttonBorder,
              ),
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
        child: _child,
      ),
    );
  }
}
