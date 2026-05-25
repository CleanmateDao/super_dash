import 'package:app_ui/src/layout/breakpoints.dart';
import 'package:app_ui/src/layout/context.dart';
import 'package:flutter/material.dart';

/// Centers page content with React-aligned gutters and a max width per breakpoint.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
    this.scrollable = false,
    this.safeArea = true,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool scrollable;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ??
        ResponsiveInsets.page(context).copyWith(
          top: ResponsiveInsets.pageVertical(context),
          bottom: ResponsiveInsets.pageVertical(context),
        );

    final resolvedMaxWidth =
        maxWidth ?? ResponsiveInsets.contentMaxWidth(context);

    Widget content = child;
    if (resolvedMaxWidth.isFinite) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
          child: child,
        ),
      );
    }

    if (scrollable) {
      content = SingleChildScrollView(
        padding: resolvedPadding,
        child: content,
      );
    } else {
      content = Padding(
        padding: resolvedPadding,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    if (backgroundColor != null) {
      return ColoredBox(
        color: backgroundColor!,
        child: content,
      );
    }

    return content;
  }
}

/// Presents a bottom sheet on phones and a centered dialog on tablet/desktop.
Future<T?> showResponsivePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AppBreakpoints.small.size) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveInsets.dialogMaxWidth(dialogContext),
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.9,
            ),
            child: Material(
              color: Colors.transparent,
              child: builder(dialogContext),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// Wraps modal/dialog content with responsive horizontal bounds.
class ResponsiveDialogFrame extends StatelessWidget {
  const ResponsiveDialogFrame({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveInsets.dialogMaxWidth(context),
        ),
        child: Padding(
          padding: ResponsiveInsets.page(context),
          child: child,
        ),
      ),
    );
  }
}
