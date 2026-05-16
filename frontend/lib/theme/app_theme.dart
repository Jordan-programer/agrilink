import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // AgriLink Angola — Agricultural Green + Harvest Amber palette
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimaryContainer = Color(0xFF002106);
  static const Color secondary = Color(0xFFF57F17);
  static const Color secondaryContainer = Color(0xFFFFE0B2);
  static const Color onSecondaryContainer = Color(0xFF4A1900);
  static const Color tertiary = Color(0xFF795548);
  static const Color tertiaryContainer = Color(0xFFD7CCC8);
  static const Color surface = Color(0xFFFAFDF6);
  static const Color surfaceVariant = Color(0xFFF1F8E9);
  static const Color background = Color(0xFFF5F9F0);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFB9F6CA);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color errorColor = Color(0xFFB71C1C);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color amber = Color(0xFFF9A825);
  static const Color earthBrown = Color(0xFF6D4C41);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF81C784);
  static const Color surfaceDark = Color(0xFF1A1C18);
  static const Color backgroundDark = Color(0xFF121412);
  static const Color surfaceVariantDark = Color(0xFF232B22);
  static const Color onSurfaceDark = Color(0xFFE2E3DC);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      error: errorColor,
      errorContainer: errorContainer,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313330),
      onInverseSurface: Color(0xFFF0F1EA),
      inversePrimary: Color(0xFF81C784),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: outline,
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primaryContainer,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primary,
            fontFamily: 'Plus Jakarta Sans',
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          fontFamily: 'Plus Jakarta Sans',
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 24);
        }
        return const IconThemeData(color: onSurfaceVariant, size: 24);
      }),
      height: 72,
      elevation: 8,
      shadowColor: Color(0x1A000000),
    ),
    dividerTheme: const DividerThemeData(
      color: outlineVariant,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF313330),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.fixed,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: Color(0xFF003909),
      primaryContainer: Color(0xFF00530F),
      onPrimaryContainer: Color(0xFF98F4A1),
      secondary: Color(0xFFFFB74D),
      onSecondary: Color(0xFF4A2800),
      secondaryContainer: Color(0xFF6A3C00),
      onSecondaryContainer: Color(0xFFFFDDB3),
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      surfaceContainerHighest: surfaceVariantDark,
      onSurfaceVariant: Color(0xFFCAC4D0),
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
      error: Color(0xFFCF6679),
      errorContainer: Color(0xFF8C1D18),
      inverseSurface: Color(0xFFE2E3DC),
      onInverseSurface: Color(0xFF2F312E),
      inversePrimary: primary,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: onSurfaceDark,
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceDark,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceDark,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: const Color(0xFF00530F),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryDark,
            fontFamily: 'Plus Jakarta Sans',
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCAC4D0),
          fontFamily: 'Plus Jakarta Sans',
        );
      }),
      height: 72,
      elevation: 8,
    ),
  );
}