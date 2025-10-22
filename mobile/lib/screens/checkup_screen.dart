import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/services/animal_service.dart';
import 'package:PetDex/components/ui/disease_prediction.dart';
import '/models/checkup_result.dart';

class CheckupScreen extends StatefulWidget {
  final String animalId;

  const CheckupScreen({super.key, required this.animalId});

  @override
  State<CheckupScreen> createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  final AnimalService _animalService = AnimalService();

  final Map<String, bool> _sintomas = {
    "perda_de_apetite": false,
    "vomito": false,
    "diarreia": false,
    "tosse": false,
    "dificuldade_para_respirar": false,
    "dificuldade_para_locomover": false,
    "problemas_na_pele": false,
    "secrecao_nasal": false,
    "secrecao_ocular": false,
    "agitacao": false,
    "andar_em_circulos": false,
    "aumento_apetite": false,
    "cera_excessiva_nas_orelhas": false,
    "coceira": false,
    "desidratacao": false,
    "desmaio": false,
    "dificuldade_para_urinar": false,
    "dor": false,
    "espamos_musculares": false,
    "espirros": false,
    "febre": false,
    "fraqueza": false,
    "inchaco": false,
    "lambedura": false,
    "letargia": false,
    "lingua_azulada": false,
    "perda_de_pelos": false,
    "perda_de_peso": false,
    "ranger_de_dentes": false,
    "ronco": false,
    "salivacao": false,
    "suor_alterado": false,
  };

  int _duracao = 0;
  bool _loading = false;
  CheckupResult? _resultado;

  void _enviarCheckup() async {
    setState(() {
      _loading = true;
      _resultado = null;
    });

    // Monta o JSON conforme a API espera
    final Map<String, dynamic> body = {
      "duracao": _duracao,
      ..._sintomas.map((key, value) => MapEntry(key, value ? 1 : 0)),
    };

    try {
      final result = await _animalService.postCheckup(widget.animalId, body);
      setState(() {
        _resultado = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao realizar checkup: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand900,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.stethoscope,
                size: 60,
                color: AppColors.orange,
              ),
              const SizedBox(height: 12),
              const Text(
                "CheckUp",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 24),

              // Se já houver resultado, exibe o diagnóstico
              if (_resultado != null) ...[
                DiseasePrediction(diseaseText: _resultado!.resultado),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _resultado = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Refazer Checkup",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
                // Campo de duração
                const Text(
                  "Há quantos dias o animal apresenta os sintomas?",
                  style: TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_duracao > 0) {
                          setState(() => _duracao--);
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: AppColors.orange,
                      ),
                    ),
                    Text(
                      "$_duracao dias",
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _duracao++);
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lista de sintomas
                const Text(
                  "Selecione os sintomas observados:",
                  style: TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._sintomas.keys.map((sintoma) {
                  return CheckboxListTile(
                    activeColor: AppColors.orange,
                    checkColor: Colors.white,
                    title: Text(
                      sintoma.replaceAll("_", " "),
                      style: const TextStyle(color: AppColors.orange),
                    ),
                    value: _sintomas[sintoma],
                    onChanged: (val) {
                      setState(() {
                        _sintomas[sintoma] = val ?? false;
                      });
                    },
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Botão enviar
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _enviarCheckup,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.pets, color: Colors.white),
                  label: Text(
                    _loading ? "Analisando..." : "Enviar Checkup",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
