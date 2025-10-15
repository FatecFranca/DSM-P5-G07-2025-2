import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:PetDex/services/map_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Carrega as variáveis do .env antes de qualquer serviço
  await dotenv.load(fileName: ".env");

  // Agora o dotenv já está disponível
  await MapServices.getEnderecoAtualDoAnimal("68194120636f719fcd5ee5fd");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Mapa e Geocoding do PetDex rodando...',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
