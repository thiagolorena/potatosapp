import 'package:flutter/material.dart';

class PotatosColors {
  static const asphalt = Color(0xFF111214);
  static const pitWall = Color(0xFF1B1D22);
  static const gridLine = Color(0xFF2D3037);
  static const racingOrange = Color(0xFFFF6210);
  static const racingRed = Color(0xFFE7362E);
  static const flagWhite = Color(0xFFF7F7F2);
  static const smoke = Color(0xFFB8BCC6);
  static const success = Color(0xFF22C55E);
}

class PotatosTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PotatosColors.racingOrange,
      brightness: Brightness.dark,
      primary: PotatosColors.racingOrange,
      secondary: PotatosColors.racingRed,
      surface: PotatosColors.pitWall,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PotatosColors.asphalt,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 0),
        headlineSmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0),
        titleLarge: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0),
        bodyMedium: TextStyle(fontSize: 14, letterSpacing: 0),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: PotatosColors.asphalt,
        foregroundColor: PotatosColors.flagWhite,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: PotatosColors.pitWall,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: PotatosColors.gridLine),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PotatosColors.pitWall,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: PotatosColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: PotatosColors.racingOrange, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PotatosColors.racingOrange,
          foregroundColor: PotatosColors.asphalt,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PotatosColors.flagWhite,
          side: const BorderSide(color: PotatosColors.gridLine),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: PotatosColors.pitWall,
        selectedColor: PotatosColors.racingOrange,
        secondarySelectedColor: PotatosColors.racingOrange,
        labelStyle: TextStyle(
            color: PotatosColors.flagWhite, fontWeight: FontWeight.w700),
        secondaryLabelStyle: TextStyle(
            color: PotatosColors.asphalt, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    );
  }

  static ThemeData light() {
    return dark();
  }
}
