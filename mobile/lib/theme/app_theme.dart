import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(Typography.blackCupertino),
    scaffoldBackgroundColor: const Color(0xFFF0D37B),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF0D37B),
    ).copyWith(
      primary: const Color(0xFFBF4904),
      secondary: const Color(0xFFF39200),
      surface: const Color(0xFFFAEDCB),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFBF4904),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
