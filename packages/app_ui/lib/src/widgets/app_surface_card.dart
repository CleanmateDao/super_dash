import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

/// Semi-transparent card surface matching React `bg-card/60` sections.
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card.withValues(alpha: 0.6),
        border: Border.all(color: tokens.border),
        borderRadius: AppRadii.lgBorder,
        boxShadow: tokens.softShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
