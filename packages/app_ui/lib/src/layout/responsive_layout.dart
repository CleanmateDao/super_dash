import 'package:app_ui/src/layout/context.dart';
import 'package:flutter/widgets.dart';

/// Signature for responsive layout builders.
typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

/// Signature for the individual builders (`small`, `large`).
typedef ResponsiveLayoutWidgetBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

/// Builds different layouts for phone, tablet, and desktop widths.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    required this.child,
    this.medium,
    this.large,
    this.extraLarge,
    super.key,
  });

  final ResponsiveWidgetBuilder compact;
  final ResponsiveWidgetBuilder? medium;
  final ResponsiveWidgetBuilder? large;
  final ResponsiveWidgetBuilder? extraLarge;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final layout = context.screenLayout;
    final builder = switch (layout) {
      ScreenLayout.extraLarge => extraLarge ?? large ?? medium ?? compact,
      ScreenLayout.large => large ?? medium ?? compact,
      ScreenLayout.medium => medium ?? compact,
      ScreenLayout.compact => compact,
    };
    return builder(context);
  }
}

/// {@template responsive_layout_builder}
/// A wrapper which exposes builders for small vs large layouts.
/// {@endtemplate}
class ResponsiveLayoutBuilder extends StatelessWidget {
  /// {@macro responsive_layout_builder}
  const ResponsiveLayoutBuilder({
    required this.small,
    required this.large,
    super.key,
    this.child,
  });

  /// [ResponsiveLayoutWidgetBuilder] for small layout.
  final ResponsiveLayoutWidgetBuilder small;

  /// [ResponsiveLayoutWidgetBuilder] for large layout.
  final ResponsiveLayoutWidgetBuilder large;

  /// Optional child widget which will be passed
  /// to the `small` and `large`
  /// builders as a way to share/optimize shared layout.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (context.isSmall) {
      return small(context, child);
    }
    return large(context, child);
  }
}
