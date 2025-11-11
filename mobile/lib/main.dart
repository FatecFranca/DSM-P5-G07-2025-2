import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/screens/login_screen.dart';
import 'package:PetDex/screens/app_shell.dart';
import 'package:PetDex/services/auth_service.dart';

final authService = AuthService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      home: FutureBuilder(
        future: authService.init(),
        builder: (context, snapshot) {
          // Enquanto inicializa
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Se o usuário já estiver autenticado, vai direto pro app
          if (authService.isAuthenticated()) {
            return Stack(
              children: [
                const AppShell(),

                /// 🔹 Botão de Logout de Teste
                Positioned(
                  right: 16,
                  top: 40,
                  child: FloatingActionButton.extended(
                    heroTag: 'logoutButton',
                    backgroundColor: Colors.redAccent,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout (teste)'),
                    onPressed: () async {
                      await authService.logout();

                      // Mostra confirmação visual
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Logout realizado com sucesso'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Redireciona para a tela de login
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          }

          // Caso contrário, volta pra tela de login
          return const LoginScreen();
        },
      ),
    );
  }
}
