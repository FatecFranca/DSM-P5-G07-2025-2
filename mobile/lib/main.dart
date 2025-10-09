import 'package:flutter/material.dart';
import '/components/ui/chart_bar.dart';
import '/models/heartbeat_data.dart';
import '/services/animal_stats_service.dart';
import '/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex Chart Test',
      theme: AppTheme.lightTheme,
      home: const ChartTestScreen(),
    );
  }
}

class ChartTestScreen extends StatefulWidget {
  const ChartTestScreen({super.key});

  @override
  State<ChartTestScreen> createState() => _ChartTestScreenState();
}

class _ChartTestScreenState extends State<ChartTestScreen> {
  final AnimalStatsService _statsService = AnimalStatsService();
  Future<List<HeartbeatData>>? _chartDataFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados quando a tela é criada
    _chartDataFuture = _statsService.getMediaUltimos5Dias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do Gráfico de Batimentos')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<HeartbeatData>>(
          future: _chartDataFuture,
          builder: (context, snapshot) {
            // Enquanto os dados estão carregando, mostra um indicador de progresso
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.orange));
            }
            // Se ocorreu um erro na API, mostra uma mensagem
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
            }
            // Se os dados chegaram com sucesso, mas a lista está vazia
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum dado encontrado.'));
            }
            // Se tudo deu certo, exibe o gráfico
            return ChartBar(data: snapshot.data!);
          },
        ),
      ),
    );
  }
}