import 'package:app_ui/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text styles used in the app.
class AppTextStyles {
  /// Creates a [AppTextStyles].
  const AppTextStyles();

  /// Package name
  static const package = 'app_ui';

  /// Creates a [TextTheme] from the text styles.
  static final TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  static final TextStyle _commonStyle = GoogleFonts.hostGrotesk(
    color: AppColors.foreground,
    decorationColor: AppColors.foreground,
  );

  /// Display large text style.
  static TextStyle get displayLarge => _commonStyle.copyWith(
        fontSize: 48,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -1,
      );

  /// Display medium text style.
  static TextStyle get displayMedium => _commonStyle.copyWith(
        fontSize: 40,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.8,
      );

  /// Display small text style.
  static TextStyle get displaySmall => _commonStyle.copyWith(
        fontSize: 32,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.6,
      );

  /// Headline large text style.
  static TextStyle get headlineLarge => _commonStyle.copyWith(
        fontSize: 32,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.5,
      );

  /// Headline medium text style.
  static TextStyle get headlineMedium => _commonStyle.copyWith(
        fontSize: 28,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.4,
      );

  /// Headline small text style.
  static TextStyle get headlineSmall => _commonStyle.copyWith(
        fontSize: 24,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.3,
      );

  /// Title large text style.
  static TextStyle get titleLarge => _commonStyle.copyWith(
        fontSize: 22,
        fontWeight: AppFontWeights.semibold,
        letterSpacing: -.2,
      );

  /// Title medium text style.
  static TextStyle get titleMedium => _commonStyle.copyWith(
        fontSize: 18,
        fontWeight: AppFontWeights.semibold,
      );

  /// Title small text style.
  static TextStyle get titleSmall => _commonStyle.copyWith(
        fontSize: 16,
        fontWeight: AppFontWeights.semibold,
      );

  /// Body large text style.
  static TextStyle get bodyLarge => _commonStyle.copyWith(
        fontSize: 16,
        height: 1.5,
      );

  /// Body medium text style.
  static TextStyle get bodyMedium => _commonStyle.copyWith(
        fontSize: 14,
        height: 1.5,
      );

  /// Body small text style.
  static TextStyle get bodySmall => _commonStyle.copyWith(
        fontSize: 12,
        height: 1.45,
      );

  /// Label large text style (`font-medium` in the React app).
  static TextStyle get labelLarge => _commonStyle.copyWith(
        fontSize: 14,
        fontWeight: AppFontWeights.medium,
      );

  /// Label medium text style (`font-medium` in the React app).
  static TextStyle get labelMedium => _commonStyle.copyWith(
        fontSize: 12,
        fontWeight: AppFontWeights.medium,
      );

  /// Label small text style (`font-medium` in the React app).
  static TextStyle get labelSmall => _commonStyle.copyWith(
        fontSize: 11,
        fontWeight: AppFontWeights.medium,
      );
}

/// Font weights aligned with Tailwind / the Cleanmate React app.
abstract final class AppFontWeights {
  /// `font-medium` (500)
  static const FontWeight medium = FontWeight.w400;

  /// `font-semibold` (600)
  static const FontWeight semibold = FontWeight.w500;

  /// `font-bold` (700)
  static const FontWeight bold = FontWeight.w600;
}
