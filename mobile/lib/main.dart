import 'package:flutter/material.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex Component Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NavBar(), // ✅ Apenas isso!
    );
  }
}