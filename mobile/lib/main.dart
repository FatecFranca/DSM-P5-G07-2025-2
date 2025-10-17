import 'package:flutter/material.dart';
import '/components/ui/status_bar.dart';
import '/services/animal_service.dart';
import '/theme/app_theme.dart';

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
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double statusBarCollapsedHeight = 150.0;

    return Scaffold(
      // 👇 COR DE FUNDO ADICIONADA AQUI 👇
      backgroundColor: Colors.orange[100], 
      appBar: AppBar(title: const Text('Tela Principal')),
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: statusBarCollapsedHeight),
            child: Center(child: Text('Bem-vindo ao PetDex!')),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StatusBar(animalId: AnimalService.unoId),
          ),
        ],
      ),
    );
  }
}