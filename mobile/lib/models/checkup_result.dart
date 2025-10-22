import 'dart:convert';

class CheckupResult {
  final String animalId;
  final Map<String, dynamic> dadosEntrada;
  final Map<String, double> probabilidades;
  final String resultado;

  CheckupResult({
    required this.animalId,
    required this.dadosEntrada,
    required this.probabilidades,
    required this.resultado,
  });

  factory CheckupResult.fromJson(Map<String, dynamic> json) {
    final probs = <String, double>{};
    if (json['probabilidades'] != null) {
      json['probabilidades'].forEach((key, value) {
        probs[key] = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
      });
    }

    return CheckupResult(
      animalId: json['animalId'] ?? '',
      dadosEntrada: json['dados_entrada'] ?? {},
      probabilidades: probs,
      resultado: json['resultado'] ?? '',
    );
  }

  @override
  String toString() {
    return jsonEncode({
      'animalId': animalId,
      'resultado': resultado,
      'probabilidades': probabilidades,
    });
  }
}
