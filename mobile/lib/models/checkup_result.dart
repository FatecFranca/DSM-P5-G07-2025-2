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
    final Map<String, dynamic> dadosEntrada =
        (json['dados_entrada'] as Map).cast<String, dynamic>();

    final Map<String, double> probabilidades =
        (json['probabilidades'] as Map)
            .cast<String, dynamic>()
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

    return CheckupResult(
      animalId: json['animalId'] as String,
      dadosEntrada: dadosEntrada,
      probabilidades: probabilidades,
      resultado: json['resultado'] as String,
    );
  }
}

