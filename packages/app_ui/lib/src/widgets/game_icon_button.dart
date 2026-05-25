import 'package:app_ui/src/theme/theme.dart';
import 'package:app_ui/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// {@template game_icon_button}
/// Icon button using the React `outline` / `secondary` surface style.
/// {@endtemplate}
class GameIconButton extends StatelessWidget {
  /// {@macro game_icon_button}
  const GameIconButton({
    required this.icon,
    this.onPressed,
    this.gradient,
    this.border,
    this.size,
    this.alignment,
    super.key,
  }) : customIcon = null;

  /// {@macro game_icon_button}
  const GameIconButton.custom({
    required this.customIcon,
    this.onPressed,
    this.gradient,
    this.border,
    this.size,
    this.alignment,
    super.key,
  }) : icon = null;

  /// The icon to display.
  final IconData? icon;

  /// The custom icon widget to display.
  final Widget? customIcon;

  /// The callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional gradient override (defaults to secondary surface).
  final List<Color>? gradient;

  /// The border to use for the button.
  final Border? border;

  /// The size of the icon.
  final double? size;

  /// The alignment of the icon.
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final surface = tokens.secondary.withValues(alpha: 0.8);

    return TraslucentBackground(
      gradient: gradient ?? [surface, surface],
      border: border ?? Border.all(color: tokens.border),
      shape: BoxShape.rectangle,
      borderRadius: AppRadii.buttonBorder,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.buttonBorder,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          alignment: alignment ?? Alignment.center,
          child: IconTheme(
            data: IconThemeData(
              size: size ?? 20,
              color: tokens.foreground,
            ),
            child: customIcon ?? Icon(icon),
          ),
        ),
      ),
    );
  }
}
