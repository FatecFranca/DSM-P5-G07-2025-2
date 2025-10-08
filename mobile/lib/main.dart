import 'package:flutter/material.dart';
import '/components/ui/pet_address_card.dart';
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
      home: const ComponentTestScreen(),
    );
  }
}

class ComponentTestScreen extends StatelessWidget {
  const ComponentTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do PetAddressCard')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: PetAddressCard(
            petName: 'Uno',
            address: 'R. Irênio Greco, 4580 - Vila Imperador, Franca - SP, 14405-101, Brasil',
          ),
        ),
      ),
    );
  }
}