import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: AppColors.primaryDark,

          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondaryLight,

          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorLight,

          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,

          outline: AppColors.border,
          outlineVariant: AppColors.divider,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // -----------------------------------------------------------------------
      // General
      // -----------------------------------------------------------------------
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),

      dividerColor: AppColors.divider,

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: _textTheme,

      // -----------------------------------------------------------------------
      // App Bar
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),

      // -----------------------------------------------------------------------
      // Elevated Button
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // -----------------------------------------------------------------------
      // Outlined Button
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // -----------------------------------------------------------------------
      // Text Button
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Input fields / Search bars
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom navigation
      // -----------------------------------------------------------------------
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),

      // Material 3 NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }

          return const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 23);
          }

          return const IconThemeData(color: AppColors.textSecondary, size: 23);
        }),
      ),

      // -----------------------------------------------------------------------
      // Chips
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabledBackground,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // -----------------------------------------------------------------------
      // Floating Action Button
      // -----------------------------------------------------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // -----------------------------------------------------------------------
      // Icons
      // -----------------------------------------------------------------------
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSizes.iconLarge,
      ),

      // -----------------------------------------------------------------------
      // Divider
      // -----------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // Dialog
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom Sheet
      // -----------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXLarge),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Snackbars
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      // -----------------------------------------------------------------------
      // Progress indicators
      // -----------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }

  // ===========================================================================
  // Typography
  // ===========================================================================

  static const TextTheme _textTheme = TextTheme(
    // Large page headings
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.2,
    ),

    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.2,
    ),

    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.2,
    ),

    // Page titles
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.25,
    ),

    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.25,
    ),

    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),

    // Card / section titles
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),

    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),

    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),

    // Body text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),

    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),

    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),

    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),

    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
}
