import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/services/animal_stats_service.dart';
import 'package:PetDex/components/ui/heart_line_chart.dart';
import '/models/heartbeat_data.dart';

class CheckupScreen extends StatefulWidget {
  const CheckupScreen({super.key});

  @override
  State<CheckupScreen> createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  late Future<List<HeartbeatData>> futureHeartbeats;
  final AnimalStatsService _statsService = AnimalStatsService();

  // TODO: Substituir pelo ID real do animal
  final String animalId = "68194120636f719fcd5ee5fd";

  @override
  void initState() {
    super.initState();
    futureHeartbeats = _statsService.getMediaUltimas5HorasRegistradas(animalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.stethoscope,
                size: 60,
                color: AppColors.orange900,
              ),
              const SizedBox(height: 12),
              const Text(
                "CheckUp",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // 🔸 Gráfico de batimentos cardíacos
              FutureBuilder<List<HeartbeatData>>(
                future: futureHeartbeats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange400,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Erro ao carregar dados: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Sem dados disponíveis nas últimas 5 horas.",
                        style: TextStyle(
                          color: AppColors.black400,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return HeartLineChart(
                    title: "Batimentos - Últimas 5 horas",
                    data: snapshot.data!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
