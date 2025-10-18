import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '/components/ui/select_date.dart';
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

class ComponentTestScreen extends StatefulWidget {
  const ComponentTestScreen({super.key});

  @override
  State<ComponentTestScreen> createState() => _ComponentTestScreenState();
}

class _ComponentTestScreenState extends State<ComponentTestScreen> {
  DateTime _activeDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do SelectDate')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectDate(
                initialDate: _activeDate,
                onDateSelected: (newDate) {
                  setState(() {
                    _activeDate = newDate;
                  });
                  print('Nova data selecionada: $newDate');
                },
              ),
              const SizedBox(height: 30),
              Text(
                'Data ativa na tela: ${_activeDate.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}