import 'package:PetDex/screens/login_screen.dart'; // 👈 importa a tela de login
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Instância global do serviço de autenticação
final authService = AuthService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Inicializa o serviço de autenticação (opcional)
  await authService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // 👇 define a tela inicial
      home: const LoginScreen(),
    );
  }
}
