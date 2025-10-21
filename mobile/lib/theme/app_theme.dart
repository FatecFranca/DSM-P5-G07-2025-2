import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color sand100 = Color(0xFFFBFBE1);
  static const Color sand200 = Color(0xFFe5e5ce);
  static const Color sand300 = Color(0xFFFAEDCB);
  static const Color sand400 = Color(0xFFf9d9aa);
  static const Color sand = Color(0xFFF0D37B);
  static const Color sand1000 = Color(0xFFeac46f);
  static const Color sand900 = Color(0xFFF0D37B);
  static const Color orange200 = Color(0xFFD89042);
  static const Color orange400 = Color(0xFFF39200);
  static const Color orange = Color(0xFFF27405);
  static const Color orange900 = Color(0xFFBF4904);
  static const Color brown = Color(0XFF754819);
  static const Color black200 = Color(0xFFB6B6B1);
  static const Color black400 = Color(0xFF565656);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(Typography.blackCupertino),
    scaffoldBackgroundColor: AppColors.sand100,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sand100,
    ).copyWith(primary: AppColors.orange900, secondary: AppColors.orange400),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.orange900,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}