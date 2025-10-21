import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';

class DiseasePrediction extends StatelessWidget {
  final String diseaseText;

  const DiseasePrediction({
    super.key,
    required this.diseaseText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 26),
      decoration: BoxDecoration(
        color: AppColors.sand900,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Segundo suas respostas ao questionário, seu animal apresenta sintomas de",
            style: GoogleFonts.poppins(
              color: AppColors.brown,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 46),
          Text(
            diseaseText,
            style: GoogleFonts.poppins(
              color: AppColors.orange900,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 46),
          Text(
            "Nossa análise não substitui uma \n visita ao veterinário.",
            style: GoogleFonts.poppins(
              color: AppColors.brown,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
