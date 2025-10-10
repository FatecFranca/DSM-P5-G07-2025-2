import 'package:flutter/material.dart';
import 'components/ui/heart_chart_bar.dart';
import '/models/heartbeat_data.dart';
import '/services/animal_stats_service.dart';
import '/theme/app_theme.dart';

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
      home: const NavBar(),
    );
  }
}
