import 'package:flutter/material.dart';
import '/components/ui/status_bar.dart';
import '/services/animal_service.dart';
import '/theme/app_theme.dart';
import '/components/ui/nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('Bem-vindo ao PetDex!')),
          StatusBar(animalId: AnimalService.unoId),
        ],
      ),
    );
  }
}
