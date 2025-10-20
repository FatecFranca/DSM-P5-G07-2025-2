import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/heartbeat_analysis.dart';
import '/services/animal_stats_service.dart';
import '/theme/app_theme.dart';

class HealthStatsCard extends StatefulWidget {
  final String animalId;

  const HealthStatsCard({super.key, required this.animalId});

  @override
  State<HealthStatsCard> createState() => _HealthStatsCardState();
}

class _HealthStatsCardState extends State<HealthStatsCard> {
  final AnimalStatsService _statsService = AnimalStatsService();
  Future<HeartbeatAnalysis>? _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _statsService.getLatestHeartbeatAnalysis(widget.animalId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HeartbeatAnalysis>(
      future: _analysisFuture,
      builder: (context, snapshot) {
        Widget cardContent; 

        if (snapshot.connectionState == ConnectionState.waiting) {
          cardContent = const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        } else if (snapshot.hasError) {
          print('Erro em HealthStatsCard: ${snapshot.error}');
          cardContent = Center(
            child: Text(
              'Erro ao carregar análise: ${snapshot.error}',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData) {
          cardContent = Center(
            child: Text(
              'Nenhuma análise encontrada.',
              style: GoogleFonts.poppins(color: AppColors.black200),
            ),
          );
        } else {
          final analysis = snapshot.data!;
          cardContent = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Análise de batimentos',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                analysis.titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.black400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                analysis.interpretacao,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.black400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Valor do batimento:',
                style: GoogleFonts.poppins(
                  color: AppColors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${analysis.batimentoAnalisado} BPM',
                style: GoogleFonts.poppins(
                  color: AppColors.black400,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: cardContent,
        );
      },
    );
  }
}