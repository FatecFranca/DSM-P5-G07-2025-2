import 'package:PetDex/screens/app_shell.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Instância global do serviço de autenticação
final authService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Inicializa o serviço de autenticação (realiza login automático)
  // O AuthService já trata erros internamente e permite que o app continue
  await authService.init();

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