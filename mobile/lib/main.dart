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
      appBar: AppBar(title: const Text('Tela Principal')),
      body: Stack(
        children: [
          const Center(
            child: Text('Bem-vindo ao PetDex!'),
          ),

          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StatusBar(animalId: AnimalService.unoId),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}