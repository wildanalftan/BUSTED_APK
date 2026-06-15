import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Shape Constants ─────────────────────────────────────────────────────────
// "Slash" bevel — sudut kiri-atas & kanan-bawah dipotong diagonal
// Dipakai di kedua theme sebagai pengganti borderRadius bulat.
const _kBevelAngle = 8.0;
final _beveledShape = BeveledRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(_kBevelAngle),
    bottomRight: Radius.circular(_kBevelAngle),
  ),
);

class AppTheme {
  // ─── DARK THEME PALETTE ───────────────────────────────────────────────────
  static const Color background    = Color(0xFF000000);
  static const Color surface       = Color(0xFF0D0D0D);
  static const Color surfaceVariant= Color(0xFF1A1A1A);
  static const Color primary       = Color(0xFFE50914);
  static const Color secondary     = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);

  // ─── STREET MURAL LIGHT THEME PALETTE ────────────────────────────────────
  static const Color muralBackground    = Color(0xFFF4EFE6); // warm concrete
  static const Color muralSurface       = Color(0xFFEBE5D8); // concrete shade
  static const Color muralSurfaceVariant= Color(0xFFFFFFFF); // paper-white panels
  static const Color muralPrimary       = Color(0xFFFF5500); // vivid spray orange
  static const Color muralAccent        = Color(0xFF00BFA5); // neon teal
  static const Color muralHighlight     = Color(0xFFFFD000); // chrome yellow
  static const Color muralMagenta       = Color(0xFFE91E8C); // hot magenta
  static const Color muralInk           = Color(0xFF111111); // marker ink
  static const Color muralTextPrimary   = Color(0xFF111111);
  static const Color muralTextSecondary = Color(0xFF555555);

  // ─────────────────────────────────────────────────────────────────────────
  // DARK THEME — Brutalist pitch-black + neon red
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        surfaceContainerHighest: surfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: textSecondary,
        error: Color(0xFFFF4D6D),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        displayMedium: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        headlineLarge: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        headlineSmall: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        titleMedium: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.outfit(
          color: textSecondary, fontSize: 12),
        labelLarge: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900,
          fontSize: 18, letterSpacing: 2),
        iconTheme: const IconThemeData(color: textPrimary),
        shape: const Border(bottom: BorderSide(color: surfaceVariant, width: 1)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: _beveledShape,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          elevation: 0,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          shape: _beveledShape,
          side: const BorderSide(color: secondary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: textSecondary, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: textSecondary, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primary, width: 2.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFFFF4D6D), width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFFFF4D6D), width: 2.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        shape: _beveledShape.copyWith(side: const BorderSide(color: surfaceVariant, width: 1)),
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        side: const BorderSide(color: textSecondary, width: 1),
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: _beveledShape,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.outfit(),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceVariant, thickness: 1, space: 0),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: _beveledShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: _beveledShape,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
        contentTextStyle: GoogleFonts.outfit(color: textSecondary),
      ),
      badgeTheme: const BadgeThemeData(backgroundColor: primary, textColor: Colors.white),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STREET MURAL LIGHT THEME
  // Aesthetic: sun-bleached concrete wall covered in vivid spray-paint murals.
  // Typography: Permanent Marker for display (graffiti energy), Outfit for body.
  // Shape: BeveledRectangleBorder — slash-cut corners khas poster jalanan.
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get streetMuralTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: muralBackground,
      primaryColor: muralPrimary,
      colorScheme: const ColorScheme.light(
        primary: muralPrimary,
        secondary: muralAccent,
        tertiary: muralMagenta,
        surface: muralSurface,
        surfaceContainerHighest: muralSurfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: muralTextPrimary,
        onSurfaceVariant: muralTextSecondary,
        outline: muralInk,
        error: Color(0xFFD32F2F),
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        // Graffiti marker for big display text
        displayLarge: GoogleFonts.permanentMarker(
          color: muralTextPrimary, letterSpacing: 2.0,
          shadows: [Shadow(color: muralPrimary.withOpacity(0.2), offset: const Offset(4, 4))]),
        displayMedium: GoogleFonts.permanentMarker(
          color: muralPrimary, letterSpacing: 1.5),
        displaySmall: GoogleFonts.permanentMarker(
          color: muralAccent, letterSpacing: 1.0),
        headlineLarge: GoogleFonts.permanentMarker(
          color: muralTextPrimary, letterSpacing: 1.5),
        headlineMedium: GoogleFonts.permanentMarker(
          color: muralTextPrimary, letterSpacing: 1.2),
        headlineSmall: GoogleFonts.permanentMarker(
          color: muralPrimary, letterSpacing: 1.0),
        // Outfit for titles & body
        titleLarge: GoogleFonts.outfit(
          color: muralTextPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        titleMedium: GoogleFonts.outfit(
          color: muralTextPrimary, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        titleSmall: GoogleFonts.outfit(
          color: muralTextSecondary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(
          color: muralTextPrimary, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.outfit(
          color: muralTextSecondary),
        bodySmall: GoogleFonts.outfit(
          color: muralTextSecondary, fontSize: 12),
        labelLarge: GoogleFonts.outfit(
          color: muralTextPrimary, fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      appBarTheme: AppBarTheme(
        // Gradient via SystemUiOverlayStyle; solid color here
        backgroundColor: muralPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.permanentMarker(
          color: Colors.white, fontSize: 20, letterSpacing: 1.5),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const Border(bottom: BorderSide(color: muralInk, width: 3)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: muralBackground,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: muralPrimary,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: muralPrimary.withOpacity(0.35),
          shape: _beveledShape.copyWith(
            side: const BorderSide(color: muralInk, width: 2)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: muralPrimary,
          shape: _beveledShape.copyWith(
            side: const BorderSide(color: muralPrimary, width: 2.5)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: muralAccent,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muralSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: muralTextSecondary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: muralTextSecondary, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: muralPrimary, width: 3),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: muralMagenta, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: muralMagenta, width: 2.5),
        ),
        labelStyle: GoogleFonts.outfit(
          color: muralTextSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        hintStyle: GoogleFonts.outfit(
          color: muralTextSecondary.withOpacity(0.6)),
        prefixIconColor: muralTextSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        // Sticker-on-wall look: white panel, offset ink shadow, bevel cut
        shape: _beveledShape.copyWith(side: const BorderSide(color: muralInk, width: 2)),
        color: muralSurfaceVariant,
        elevation: 6,
        shadowColor: const Color(0x55000000),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: muralHighlight,
        labelStyle: GoogleFonts.outfit(
          color: muralInk, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        side: const BorderSide(color: muralInk, width: 1.5),
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: muralAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: _beveledShape.copyWith(side: const BorderSide(color: muralInk, width: 2)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: muralBackground,
        selectedItemColor: muralPrimary,
        unselectedItemColor: muralTextSecondary,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.outfit(),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: muralInk, thickness: 2, space: 0),
      iconTheme: const IconThemeData(color: muralTextPrimary, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: muralInk,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
        actionTextColor: muralHighlight,
        behavior: SnackBarBehavior.floating,
        shape: _beveledShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: muralSurfaceVariant,
        shape: _beveledShape.copyWith(side: const BorderSide(color: muralInk, width: 2)),
        titleTextStyle: GoogleFonts.permanentMarker(
          color: muralTextPrimary, fontSize: 20, letterSpacing: 1),
        contentTextStyle: GoogleFonts.outfit(color: muralTextSecondary),
      ),
      badgeTheme: const BadgeThemeData(backgroundColor: muralMagenta, textColor: Colors.white),
    );
  }
}
