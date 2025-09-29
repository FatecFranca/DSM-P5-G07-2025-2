import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(Typography.blackCupertino),
    scaffoldBackgroundColor: const Color(0xFFFAEDCB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFAEDCB),
    ).copyWith(
      primary: const Color(0xFFF39200),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF39200),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
