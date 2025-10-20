class HeartbeatAnalysis {
  final String titulo;
  final String interpretacao;
  final int batimentoAnalisado;

  HeartbeatAnalysis({
    required this.titulo,
    required this.interpretacao,
    required this.batimentoAnalisado,
  });

  factory HeartbeatAnalysis.fromJson(Map<String, dynamic> json) {
    // Extrai o número da string "71 BPM" ou converte se for número
    int batimento = 0;
    final batimentoValue = json['batimento_analisado'];

    if (batimentoValue is String) {
      // Remove "BPM" e espaços, extrai apenas o número
      final numericPart = batimentoValue.replaceAll(RegExp(r'[^0-9]'), '');
      batimento = int.tryParse(numericPart) ?? 0;
    } else if (batimentoValue is num) {
      batimento = batimentoValue.toInt();
    }

    return HeartbeatAnalysis(
      titulo: json['titulo'] ?? 'Análise Indisponível',
      interpretacao: json['interpretacao'] ?? 'Não foi possível carregar a interpretação.',
      batimentoAnalisado: batimento,
    );
  }
}