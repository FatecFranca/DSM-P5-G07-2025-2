import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '/components/ui/heart_date_card.dart';
import '/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
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
      home: const ComponentTestScreen(),
    );
  }
}

class ComponentTestScreen extends StatelessWidget {
  const ComponentTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do HeartDateCard')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: HeartDateCard(),
        ),
      ),
    );
  }
}