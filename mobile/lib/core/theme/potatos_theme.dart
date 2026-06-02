import 'package:flutter/material.dart';

class PotatosColors {
  static const asphalt = Color(0xFF111214);
  static const pitWall = Color(0xFF1B1D22);
  static const gridLine = Color(0xFF2D3037);
  static const potatoYellow = Color(0xFFF5C542);
  static const racingRed = Color(0xFFE7362E);
  static const flagWhite = Color(0xFFF7F7F2);
  static const smoke = Color(0xFFB8BCC6);
  static const success = Color(0xFF22C55E);
}

class PotatosTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PotatosColors.potatoYellow,
      brightness: Brightness.dark,
      primary: PotatosColors.potatoYellow,
      secondary: PotatosColors.racingRed,
      surface: PotatosColors.pitWall,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PotatosColors.asphalt,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: PotatosColors.asphalt,
        foregroundColor: PotatosColors.flagWhite,
        elevation: 0,
      ),
      cardTheme: CardTheme(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PotatosColors.potatoYellow,
          foregroundColor: PotatosColors.asphalt,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static ThemeData light() {
    return dark();
  }
}
