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
    return HeartbeatAnalysis(
      titulo: json['titulo'] ?? 'Análise Indisponível',
      interpretacao: json['interpretacao'] ?? 'Não foi possível carregar a interpretação.',
      batimentoAnalisado: (json['batimento_analisado'] as num).toInt(),
    );
  }
}