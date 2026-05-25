import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

/// Cleanmate design tokens translated from the web Tailwind theme.
abstract final class AppColors {
  static const background = Color(0xFFF5F5F5);
  static const foreground = Color(0xFF1A1A1A);

  static const card = Color(0xFFFFFFFF);
  static const cardForeground = foreground;

  /// hsl(24 95% 53%)
  static const primary = Color(0xFFF97316);

  /// hsl(20 90% 45%) — gradient-primary end
  static const primaryDark = Color(0xFFD9570C);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const secondary = Color(0xFFEBEBEB);
  static const secondaryForeground = Color(0xFF262626);

  static const muted = Color(0xFFE6E6E6);
  static const mutedForeground = Color(0xFF737373);

  /// hsl(24 100% 60%)
  static const accent = Color(0xFFFF8533);

  /// hsl(35 95% 55%)
  static const accentDark = Color(0xFFE8A831);

  /// hsl(0 72% 51%)
  static const destructive = Color(0xFFDF2B2B);
  static const border = Color(0xFFE0E0E0);
  static const input = border;

  static const yellow = Color(0xFFECC02C);
  static const yellowDark = Color(0xFFE49B12);

  /// hsl(200 100% 65%)
  static const blue = Color(0xFF52C5FF);

  /// hsl(200 95% 55%)
  static const blueDark = Color(0xFF1AABF2);

  static const success = Color(0xFF30A360);
  static const darkShadow = Color(0x261A1A1A);
}

class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryDark,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentDark,
    required this.blue,
    required this.blueDark,
    required this.destructive,
    required this.border,
    required this.input,
    required this.success,
    required this.cardGradient,
    required this.softShadow,
    required this.cardShadow,
    required this.blockPrimaryShadow,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryDark;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentDark;
  final Color blue;
  final Color blueDark;
  final Color destructive;
  final Color border;
  final Color input;
  final Color success;
  final LinearGradient cardGradient;
  final List<BoxShadow> softShadow;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> blockPrimaryShadow;

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryDark],
      );

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accentDark],
      );

  LinearGradient get blueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [blue, blueDark],
      );

  static const light = AppThemeTokens(
    background: Color(0xFFF5F5F5),
    foreground: Color(0xFF1A1A1A),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF1A1A1A),
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFEBEBEB),
    secondaryForeground: Color(0xFF262626),
    muted: Color(0xFFE6E6E6),
    mutedForeground: Color(0xFF737373),
    accent: AppColors.accent,
    accentDark: AppColors.accentDark,
    blue: AppColors.blue,
    blueDark: AppColors.blueDark,
    destructive: AppColors.destructive,
    border: Color(0xFFE0E0E0),
    input: Color(0xFFE0E0E0),
    success: Color(0xFF30A360),
    cardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xCCFFFFFF), Color(0x99FAFAFA)],
    ),
    softShadow: AppShadows.soft,
    cardShadow: AppShadows.card,
    blockPrimaryShadow: AppShadows.blockPrimary,
  );

  static const dark = AppThemeTokens(
    background: Color(0xFF0F0F0F),
    foreground: Color(0xFFEBEBEB),
    card: Color(0xFF1A1A1A),
    cardForeground: Color(0xFFEBEBEB),
    primary: Color(0xFFFA7A1A),
    primaryDark: Color(0xFFE35D11),
    primaryForeground: Color(0xFF140C06),
    secondary: Color(0xFF242424),
    secondaryForeground: Color(0xFFD9D9D9),
    muted: Color(0xFF292929),
    mutedForeground: Color(0xFF8C8C8C),
    accent: Color(0xFFE85A0A),
    accentDark: Color(0xFFD1941A),
    blue: Color(0xFF22B7F2),
    blueDark: Color(0xFF0B82BF),
    destructive: Color(0xFFBA2C2C),
    border: Color(0xFF2E2E2E),
    input: Color(0xFF2E2E2E),
    success: Color(0xFF30A360),
    cardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xCC1F1F1F), Color(0x991A1A1A)],
    ),
    softShadow: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
    cardShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    blockPrimaryShadow: [
      BoxShadow(
        color: Color(0xFF8F3005),
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  AppThemeTokens copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? primary,
    Color? primaryDark,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentDark,
    Color? blue,
    Color? blueDark,
    Color? destructive,
    Color? border,
    Color? input,
    Color? success,
    LinearGradient? cardGradient,
    List<BoxShadow>? softShadow,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? blockPrimaryShadow,
  }) {
    return AppThemeTokens(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      blue: blue ?? this.blue,
      blueDark: blueDark ?? this.blueDark,
      destructive: destructive ?? this.destructive,
      border: border ?? this.border,
      input: input ?? this.input,
      success: success ?? this.success,
      cardGradient: cardGradient ?? this.cardGradient,
      softShadow: softShadow ?? this.softShadow,
      cardShadow: cardShadow ?? this.cardShadow,
      blockPrimaryShadow: blockPrimaryShadow ?? this.blockPrimaryShadow,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;

    return AppThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground:
          Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueDark: Color.lerp(blueDark, other.blueDark, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      success: Color.lerp(success, other.success, t)!,
      cardGradient: t < .5 ? cardGradient : other.cardGradient,
      softShadow: t < .5 ? softShadow : other.softShadow,
      cardShadow: t < .5 ? cardShadow : other.cardShadow,
      blockPrimaryShadow:
          t < .5 ? blockPrimaryShadow : other.blockPrimaryShadow,
    );
  }
}

extension AppThemeTokensX on BuildContext {
  AppThemeTokens get appTheme {
    return Theme.of(this).extension<AppThemeTokens>() ?? AppThemeTokens.light;
  }
}

extension AppThemeTokensStyleX on AppThemeTokens {
  /// Block shadow matching the button gradient variant (React `shadow-block-*`).
  List<BoxShadow> blockShadowForGradient(Gradient? gradient) {
    if (gradient is! LinearGradient || gradient.colors.isEmpty) {
      return blockPrimaryShadow;
    }
    final lead = gradient.colors.first;
    if (lead == blue || lead == blueDark) {
      return AppShadows.blockBlue;
    }
    if (lead == destructive) {
      return AppShadows.blockDestructive;
    }
    if (lead == accent || lead == accentDark) {
      return AppShadows.blockAccent;
    }
    return blockPrimaryShadow;
  }

  /// Label color for gradient buttons (`text-primary-foreground` / `text-white`).
  Color labelColorForGradient(Gradient? gradient) {
    return primaryForeground;
  }
}

abstract final class AppGradients {
  static const soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.background,
      Color(0xFFF0F0F0),
    ],
  );

  static const card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xCCFFFFFF),
      Color(0x99FAFAFA),
    ],
  );

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryDark,
    ],
  );

  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accent,
      AppColors.accentDark,
    ],
  );

  static const yellow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.yellow,
      AppColors.yellowDark,
    ],
  );

  static const blue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.blue,
      AppColors.blueDark,
    ],
  );
}

abstract final class AppRadii {
  /// `--radius` / Tailwind `rounded-lg` (0.75rem).
  static const Radius button = Radius.circular(12);
  static const BorderRadius buttonBorder = BorderRadius.all(button);

  static const Radius md = Radius.circular(12);
  static const BorderRadius mdBorder = BorderRadius.all(md);

  /// Tailwind `rounded-2xl` (1rem).
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(24));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x0A1A1A1A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A1A1A1A),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0F1A1A1A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A1A1A1A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: Color(0x1A1A1A1A),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F1A1A1A),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  /// hsl(20 90% 35%) — `shadow-block-primary`
  static const blockPrimary = [
    BoxShadow(
      color: Color(0xFF9A3D08),
      offset: Offset(0, 4),
    ),
  ];

  /// hsl(200 95% 40%) — `shadow-block-blue`
  static const blockBlue = [
    BoxShadow(
      color: Color(0xFF0D7AB8),
      offset: Offset(0, 4),
    ),
  ];

  /// hsl(0 72% 35%) — `shadow-block-destructive`
  static const blockDestructive = [
    BoxShadow(
      color: Color(0xFF9C1E1E),
      offset: Offset(0, 4),
    ),
  ];

  /// hsl(35 95% 40%) — `shadow-block-accent`
  static const blockAccent = [
    BoxShadow(
      color: Color(0xFFB87A12),
      offset: Offset(0, 4),
    ),
  ];

  /// hsl(0 0% 75%) — `shadow-block-secondary` / outline
  static const blockSecondary = [
    BoxShadow(
      color: Color(0xFFBFBFBF),
      offset: Offset(0, 4),
    ),
  ];
}
