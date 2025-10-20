import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/models/heartbeat_analysis.dart';

void main() {
  group('HealthStatsCard - HeartbeatAnalysis', () {
    test('Deve fazer parse correto dos dados da API com todos os campos',
        () {
      // Arrange
      final apiResponse = {
        'valor_informado': 71,
        'media_registrada': 69,
        'desvio_padrao': 21,
        'probabilidade_percentual': 90.57,
        'classificacao': 'Dentro do esperado',
        'titulo': 'Batimento esperado ✅',
        'interpretacao':
            'O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias.',
        'batimento_analisado': '71 BPM',
        'avaliacao':
            'O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias.',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(apiResponse);

      // Assert
      expect(analysis.titulo, equals('Batimento esperado ✅'));
      expect(
        analysis.interpretacao,
        contains('dentro do comportamento normal'),
      );
      expect(analysis.batimentoAnalisado, equals(71));
    });

    test('Deve usar o título da API em vez de texto hardcoded', () {
      // Arrange
      final apiResponse = {
        'titulo': 'Batimento esperado ✅',
        'interpretacao': 'Teste de interpretação',
        'batimento_analisado': '71 BPM',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(apiResponse);

      // Assert - Verifica que o título vem da API
      expect(analysis.titulo, isNotEmpty);
      expect(analysis.titulo, equals('Batimento esperado ✅'));
    });

    test('Deve usar a interpretação da API em vez de texto hardcoded', () {
      // Arrange
      final apiResponse = {
        'titulo': 'Teste',
        'interpretacao':
            'O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias.',
        'batimento_analisado': '71 BPM',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(apiResponse);

      // Assert - Verifica que a interpretação vem da API
      expect(analysis.interpretacao, isNotEmpty);
      expect(
        analysis.interpretacao,
        contains('dentro do comportamento normal'),
      );
    });

    test('Deve exibir o valor correto do batimento analisado', () {
      // Arrange
      final apiResponse = {
        'titulo': 'Teste',
        'interpretacao': 'Teste',
        'batimento_analisado': '71 BPM',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(apiResponse);

      // Assert - Verifica que o batimento é extraído corretamente
      expect(analysis.batimentoAnalisado, equals(71));
    });

    test('Deve fazer parse com diferentes títulos da API', () {
      // Arrange
      final apiResponse1 = {
        'titulo': 'Batimento esperado ✅',
        'interpretacao': 'Teste',
        'batimento_analisado': '71 BPM',
      };

      final apiResponse2 = {
        'titulo': 'Batimento acima do esperado ⚠️',
        'interpretacao': 'Teste',
        'batimento_analisado': '120 BPM',
      };

      // Act
      final analysis1 = HeartbeatAnalysis.fromJson(apiResponse1);
      final analysis2 = HeartbeatAnalysis.fromJson(apiResponse2);

      // Assert
      expect(analysis1.titulo, equals('Batimento esperado ✅'));
      expect(analysis2.titulo, equals('Batimento acima do esperado ⚠️'));
      expect(analysis1.titulo, isNot(equals(analysis2.titulo)));
    });
  });
}

