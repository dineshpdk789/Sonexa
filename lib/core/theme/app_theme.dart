import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Seed color – deep violet/purple
  static const Color _seedColor = Color(0xFF7C4DFF);
  static const Color _amoledBackground = Color(0xFF000000);

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(cs);
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _buildTheme(cs);
  }

  // ── AMOLED Black Theme ───────────────────────────────────────────────────────
  static ThemeData get amoledTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: _amoledBackground,
      background: _amoledBackground,
    );
    return _buildTheme(cs).copyWith(
      scaffoldBackgroundColor: _amoledBackground,
    );
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    final textTheme = GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge:
            TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: cs.onSurface),
        displayMedium:
            TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: cs.onSurface),
        headlineLarge:
            TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface),
        headlineMedium:
            TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: cs.onSurface),
        headlineSmall:
            TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: cs.onSurface),
        titleLarge:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface),
        titleMedium:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface),
        titleSmall:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
        bodyLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: cs.onSurface),
        bodyMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: cs.onSurface),
        bodySmall:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
        labelMedium:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
        labelSmall:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,
      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
        actionsIconTheme: IconThemeData(color: cs.onSurface),
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerHighest.withOpacity(0.3),
      ),
      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cs.surface.withOpacity(0.95),
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: cs.onSurfaceVariant,
          );
        }),
      ),
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface.withOpacity(0.85),
        modalBackgroundColor: cs.surface.withOpacity(0.85),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface.withOpacity(0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      // Slider
      sliderTheme: SliderThemeData(
        thumbColor: cs.primary,
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.onSurface.withOpacity(0.15),
        overlayColor: cs.primary.withOpacity(0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(cs.onSurface),
        ),
      ),
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: cs.onSurface.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),
      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
