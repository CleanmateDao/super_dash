import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

abstract final class AppTheme {
  static ThemeData light() => _theme(AppThemeTokens.light, Brightness.light);

  static ThemeData dark() => _theme(AppThemeTokens.dark, Brightness.dark);

  static ThemeData _theme(AppThemeTokens tokens, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.primaryForeground,
      secondary: tokens.secondary,
      onSecondary: tokens.secondaryForeground,
      surface: tokens.card,
      onSurface: tokens.cardForeground,
      error: tokens.destructive,
      onError: AppColors.primaryForeground,
    );

    final textTheme = AppTextStyles.textTheme.apply(
      bodyColor: tokens.foreground,
      displayColor: tokens.foreground,
      decorationColor: tokens.foreground,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      textTheme: textTheme,
      extensions: [tokens],
      cardTheme: CardThemeData(
        color: tokens.card,
        shadowColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.mdBorder,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card,
        labelStyle: TextStyle(color: tokens.mutedForeground),
        hintStyle: TextStyle(color: tokens.mutedForeground),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide(color: tokens.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide(color: tokens.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdBorder,
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: AppFontWeights.medium,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.primaryForeground,
          disabledBackgroundColor: tokens.muted,
          disabledForegroundColor: tokens.mutedForeground,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonBorder,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: AppFontWeights.medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.foreground,
          backgroundColor: tokens.background.withValues(alpha: 0.6),
          side: BorderSide(color: tokens.border),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonBorder,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: AppFontWeights.medium,
          ),
        ),
      ),
    );
  }
}
