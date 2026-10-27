import 'package:flutter/material.dart';

const primaryPurple = Color(0xFF5421A8);
const darkPurple = Color(0xFF321064);
const lightPurple = Color(0xFFF0E8FF);
const pageBackground = Color(0xFFF8F7FC);

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pageBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryPurple),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: darkPurple),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEDE8F5)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9F7FD),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5DDF1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryPurple, width: 1.5)),
    ),
  );
}
