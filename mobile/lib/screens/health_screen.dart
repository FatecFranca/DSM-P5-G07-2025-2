import 'package:PetDex/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/heart_chart_bar.dart';
import 'package:PetDex/components/ui/heart_date_card.dart';
import 'package:PetDex/components/ui/health_stats_card.dart';
import 'package:PetDex/services/animal_stats_service.dart';
import 'package:PetDex/models/heartbeat_data.dart';
import 'package:PetDex/services/auth_service.dart';

class HealthScreen extends StatefulWidget {
  final String? animalId;
  final String? animalName;

  const HealthScreen({super.key, this.animalId, this.animalName});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late final AnimalStatsService _statsService;
  late Future<List<HeartbeatData>> _mediasFuture;
  String? _animalId;
  String? _animalName;
  bool _hasInit = false;

  @override
  void initState() {
    super.initState();
    _statsService = AnimalStatsService();
    _initializeValues();
  }

  void _initializeValues() {
    // Prioridade: parâmetro recebido -> authService -> null
    _animalId = widget.animalId ?? (authService.getAnimalId());
    _animalName = widget.animalName ?? (authService.getPetName());

    if (_animalId != null && _animalId!.isNotEmpty) {
      _mediasFuture = _statsService.getMediaUltimos5Dias(_animalId!);
    } else {
      _mediasFuture = Future.value(<HeartbeatData>[]);
    }

    _hasInit = true;
  }

  @override
  Widget build(BuildContext context) {
    // Garante que _initializeValues foi executado (em casos raros)
    if (!_hasInit) {
      _initializeValues();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              Text(
                "Painel de Saúde",
                style: GoogleFonts.poppins(
                  color: AppColors.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Frequência cardíaca, padrões de atividade e informações de saúde reunidas em um só lugar.\nTenha controle total da saúde do seu pet.",
                style: const TextStyle(fontSize: 14, color: AppColors.black400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (_animalId == null || _animalId!.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sand300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "ID do animal não encontrado. Faça login novamente ou selecione um pet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.black400),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // 1) HeartChartBar — obtém dados e passa title + data como o componente exige
                FutureBuilder<List<HeartbeatData>>(
                  future: _mediasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange900,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sand300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Erro ao carregar gráfico: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final data = snapshot.data ?? <HeartbeatData>[];

                    if (data.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sand300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Sem dados dos últimos dias para exibir no gráfico.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.black400),
                        ),
                      );
                    }

                    return HeartChartBar(
                      title: "Média de batimentos dos últimos cinco dias:",
                      data: data,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 2) HeartDateCard — passa animalId (componente usa esse ID para requisições)
                HeartDateCard(animalId: _animalId!),

                const SizedBox(height: 20),

                // 3) HealthStatsCard — passa animalId (componente usa esse ID para requisições)
                HealthStatsCard(animalId: _animalId!),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
