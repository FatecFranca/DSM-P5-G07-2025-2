import 'package:flutter/material.dart';
import 'components/ui/select_species.dart';
import 'enums/species.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex Component Test',
      theme: ThemeData.light(),
      home: const ComponentTestScreen(),
    );
  }
}

class ComponentTestScreen extends StatefulWidget {
  const ComponentTestScreen({super.key});

  @override
  State<ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<ComponentTestScreen> {
  Species _selectedSpecies = Species.dog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Teste do Seletor de Espécie')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SelectSpecies(
              initialValue: _selectedSpecies,
              onChanged: (species) {
                setState(() {
                  _selectedSpecies = species;
                });
                print('Espécie selecionada: $species');
              },
            ),
            const SizedBox(height: 40),
            Text(
              'Estado atual: ${_selectedSpecies.toString()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}