import 'package:app_ui/src/layout/context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// {@template page_with_background}
/// A page with a background for responsive design.
/// {@endtemplate}
class PageWithBackground extends StatelessWidget {
  /// {@macro page_with_background}
  const PageWithBackground({
    required this.background,
    required this.child,
    super.key,
  });

  /// The background widget.
  final Widget background;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final layout = context.screenLayout;

    final letterbox = kIsWeb
        ? layout != ScreenLayout.compact && size.aspectRatio > 0.65
        : size.aspectRatio > 0.56;

    if (letterbox) {
      final gameWidth = switch (layout) {
        ScreenLayout.medium => size.width * 0.62,
        ScreenLayout.large => size.width * 0.5,
        ScreenLayout.extraLarge => size.width * 0.45,
        ScreenLayout.compact => size.width,
      };
      final maxGameWidth = gameWidth.clamp(360.0, 720.0);

      return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            background,
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxGameWidth,
                maxHeight: size.height,
              ),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          background,
          child,
        ],
      ),
    );
  }
}
