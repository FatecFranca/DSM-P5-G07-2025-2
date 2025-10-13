import 'package:flutter/material.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/nav_bar.dart';
import 'package:PetDex/components/ui/animal_pin.dart';
import 'package:PetDex/services/animal_stats_service.dart';

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
      theme: AppTheme.lightTheme,
      home: const NavBarWithLocationTest(),
    );
  }
}

class NavBarWithLocationTest extends StatefulWidget {
  const NavBarWithLocationTest({super.key});

  @override
  State<NavBarWithLocationTest> createState() => _NavBarWithLocationTestState();
}

class _NavBarWithLocationTestState extends State<NavBarWithLocationTest> {
  final AnimalStatsService _animalService = AnimalStatsService();

  @override
  void initState() {
    super.initState();
    testarConsultaLocalizacao();
  }

  Future<void> testarConsultaLocalizacao() async {
    try {
      final resultado = await _animalService.getUltimaLocalizacaoAnimal(
        '68194120636f719fcd5ee5fd', // ID do animal para teste
      );

      if (resultado != null) {
        print('✅ Última localização recebida com sucesso!');
        print('Latitude: ${resultado['latitude']}');
        print('Longitude: ${resultado['longitude']}');
      } else {
        print('⚠️ Nenhuma localização encontrada para o animal informado.');
      }
    } catch (e) {
      print('❌ Erro ao buscar localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      body: const Center(
      
        ),
      
    );
  }
}
