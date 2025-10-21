import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/disease_prediction.dart';

class CheckupScreen extends StatelessWidget {
  const CheckupScreen({super.key});

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

              // 🧩 Novo componente de previsão de doença
              const DiseasePrediction(
                diseaseText: "Doenças gastrointestinais",
              ),
            ],
          ),
        ),
      ),
    );
  }
}