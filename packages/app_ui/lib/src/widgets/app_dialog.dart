import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_dialog}
/// A dialog with a close button in the top right corner.
/// {@endtemplate}
class AppDialog extends StatelessWidget {
  /// {@macro app_dialog}
  const AppDialog({
    required this.child,
    this.showCloseButton = true,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = AppRadii.xlBorder,
    this.border,
    this.imageProvider,
    super.key,
  });

  /// The content of the dialog.
  final Widget child;

  /// Whether to show a close button in the top right corner.
  final bool showCloseButton;

  /// The background color of the dialog. Shown behind the [gradient].
  final Color? backgroundColor;

  /// The gradient of the dialog. Shown on top of the [backgroundColor].
  final LinearGradient? gradient;

  /// The border radius of the dialog.
  final BorderRadius borderRadius;

  /// The border of the dialog.
  final BoxBorder? border;

  /// The background image of the dialog. Setting the image makes the [gradient]
  /// and [backgroundColor] invisible. Also removes the border.
  final ImageProvider<Object>? imageProvider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: AppCard(
        border: border ?? Border.all(color: tokens.border),
        gradient: gradient ?? tokens.cardGradient,
        backgroundColor: backgroundColor ?? tokens.card,
        borderRadius: borderRadius,
        imageProvider: imageProvider,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCloseButton) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GameIconButton(
                      icon: Icons.close_outlined,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
