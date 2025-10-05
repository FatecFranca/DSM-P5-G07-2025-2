import 'package:flutter/material.dart';
import 'components/ui/input.dart';
import 'enums/input_size.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex Input Test',
      theme: AppTheme.lightTheme,
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
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _nameController2 = TextEditingController();
  final _dateController2 = TextEditingController();
  final _nicknameController2 = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _nicknameController.dispose();
    _nameController2.dispose();
    _dateController2.dispose();
    _nicknameController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do Componente de Input')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Input(
              label: 'Nome',
              hintText: 'Insira o nome completo',
              controller: _nameController,
              icon: Icons.star,
              size: InputSize.large,
            ),
            const SizedBox(height: 20),
            Input(
              label: 'Data de nascimento',
              hintText: 'Insira a data',
              controller: _dateController,
              icon: Icons.calendar_today,
              size: InputSize.medium,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            Input(
              label: 'Apelido',
              hintText: 'Insira o apelido',
              controller: _nicknameController,
              icon: Icons.check_circle,
              size: InputSize.small,
            ),

            const Divider(height: 60),

            Input(
              label: 'Nome',
              hintText: 'Insira o nome completo',
              controller: _nameController2,
              size: InputSize.large,
            ),
            const SizedBox(height: 20),
            Input(
              label: 'Data',
              hintText: 'Insira a data',
              controller: _dateController2,
              size: InputSize.medium,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            Input(
              label: 'Apelido',
              hintText: 'Insira o apelido',
              controller: _nicknameController2,
              size: InputSize.small,
            ),
          ],
        ),
      ),
    );
  }
}