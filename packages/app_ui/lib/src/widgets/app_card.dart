import 'package:app_ui/src/layout/context.dart';
import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

/// {@template app_card}
/// An app themed card.
/// {@endtemplate}
class AppCard extends StatelessWidget {
  /// {@macro app_card}
  const AppCard({
    required this.child,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = AppRadii.xlBorder,
    this.border,
    this.imageProvider,
    super.key,
  });

  /// The content of the card.
  final Widget child;

  /// The background color of the card. Shown behind the [gradient].
  final Color? backgroundColor;

  /// The gradient of the card. Shown on top of the [backgroundColor].
  final LinearGradient? gradient;

  /// The border radius of the card.
  final BorderRadius? borderRadius;

  /// The border of the card.
  final BoxBorder? border;

  /// The background image of the card. Setting the image makes the [gradient]
  /// and [backgroundColor] invisible. Also removes the border.
  final ImageProvider<Object>? imageProvider;

  @override
  Widget build(BuildContext context) {
    final showImage = imageProvider != null;
    final tokens = context.appTheme;

    final maxDialogWidth = ResponsiveInsets.dialogMaxWidth(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxDialogWidth,
        maxHeight: 624,
      ),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: showImage ? null : border,
        color: showImage ? null : backgroundColor ?? tokens.card,
        boxShadow: showImage ? null : tokens.cardShadow,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: showImage ? null : gradient ?? tokens.cardGradient,
          image: showImage
              ? DecorationImage(
                  image: imageProvider!,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}
