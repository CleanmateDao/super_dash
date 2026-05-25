import 'package:app_ui/src/layout/breakpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Layout bucket aligned with Tailwind breakpoints.
enum ScreenLayout {
  /// &lt; 640px — phone
  compact,

  /// 640px–1023px — large phone / tablet
  medium,

  /// 1024px–1399px — desktop
  large,

  /// ≥ 1400px — wide desktop
  extraLarge,
}

/// Extension on [BuildContext] to provide information about the layout.
extension BuildContextLayoutX on BuildContext {
  ScreenLayout get screenLayout {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.extraLarge.size) {
      return ScreenLayout.extraLarge;
    }
    if (width >= 1024) {
      return ScreenLayout.large;
    }
    if (width >= 640) {
      return ScreenLayout.medium;
    }
    return ScreenLayout.compact;
  }

  /// Width below Tailwind `sm` (640px).
  bool get isCompact => screenLayout == ScreenLayout.compact;

  /// Width below Tailwind `md` (768px).
  bool get isSmall {
    final isNarrow =
        MediaQuery.sizeOf(this).width < AppBreakpoints.small.size;
    if (kIsWeb) {
      return isNarrow;
    }
    return isNarrow && MediaQuery.of(this).orientation == Orientation.portrait;
  }

  /// Tablet range (640px–1023px).
  bool get isTablet =>
      screenLayout == ScreenLayout.medium;

  /// Width at or above Tailwind `lg` (1024px).
  bool get isLarge =>
      screenLayout == ScreenLayout.large ||
      screenLayout == ScreenLayout.extraLarge;

  /// Width at or above Tailwind `2xl` container (1400px).
  bool get isExtraLarge => screenLayout == ScreenLayout.extraLarge;

  /// Use the desktop intro/background asset from tablet width upward.
  bool get useDesktopVisuals =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.small.size;
}

/// Page padding aligned with the Cleanmate React app (`px-4 sm:px-6 lg:px-10`).
abstract final class ResponsiveInsets {
  /// Horizontal page gutters matching the React app.
  static EdgeInsets page(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.medium.size) {
      return const EdgeInsets.symmetric(horizontal: 40);
    }
    if (width >= 640) {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static double pageVertical(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => 16,
      ScreenLayout.medium => 24,
      ScreenLayout.large => 28,
      ScreenLayout.extraLarge => 32,
    };
  }

  /// Default content column (`max-w-3xl` on desktop).
  static double contentMaxWidth(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => double.infinity,
      ScreenLayout.medium => 640,
      ScreenLayout.large => 768,
      ScreenLayout.extraLarge => 896,
    };
  }

  /// Wider grids (locations, etc.).
  static double wideContentMaxWidth(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => double.infinity,
      ScreenLayout.medium => 720,
      ScreenLayout.large => 1024,
      ScreenLayout.extraLarge => 1200,
    };
  }

  /// Modal / dialog max width.
  static double dialogMaxWidth(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => MediaQuery.sizeOf(context).width - 32,
      ScreenLayout.medium => 520,
      ScreenLayout.large => 480,
      ScreenLayout.extraLarge => 520,
    };
  }

  /// Grid column count for card grids.
  static int gridCrossAxisCount(
    BuildContext context, {
    int compact = 2,
    int medium = 3,
    int large = 4,
    int extraLarge = 4,
  }) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => compact,
      ScreenLayout.medium => medium,
      ScreenLayout.large => large,
      ScreenLayout.extraLarge => extraLarge,
    };
  }

  static double gridChildAspectRatio(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => 0.82,
      ScreenLayout.medium => 0.78,
      ScreenLayout.large => 0.76,
      ScreenLayout.extraLarge => 0.8,
    };
  }

  /// Intro / branding logo width.
  static double logoWidth(BuildContext context) {
    return switch (context.screenLayout) {
      ScreenLayout.compact => 260,
      ScreenLayout.medium => 320,
      ScreenLayout.large => 360,
      ScreenLayout.extraLarge => 400,
    };
  }

  /// Leaderboard panel size inside [PageWithBackground].
  static Size leaderboardPanelSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalGutter = page(context).horizontal * 2 + 32;
    final maxWidth = switch (context.screenLayout) {
      ScreenLayout.compact => size.width - horizontalGutter,
      ScreenLayout.medium => 440,
      ScreenLayout.large => 480,
      ScreenLayout.extraLarge => 520,
    };
    final width = maxWidth.clamp(280.0, size.width - horizontalGutter);
    final maxHeight = switch (context.screenLayout) {
      ScreenLayout.compact => size.height * 0.58,
      ScreenLayout.medium => size.height * 0.62,
      _ => size.height * 0.65,
    };
    final height = maxHeight.clamp(360.0, 560.0);
    return Size(width.toDouble(), height.toDouble());
  }

  /// Instructions carousel viewport inside dialogs.
  static Size instructionsViewportSize(BuildContext context) {
    final dialogWidth = dialogMaxWidth(context) - 48;
    final width = dialogWidth.clamp(280.0, 480.0);
    final height = switch (context.screenLayout) {
      ScreenLayout.compact => 360,
      ScreenLayout.medium => 400,
      _ => 420,
    };
    return Size(width.toDouble(), height.toDouble());
  }
}
