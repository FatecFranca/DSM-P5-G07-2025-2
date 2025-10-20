import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/models/heartbeat_analysis.dart';

void main() {
  group('HeartbeatAnalysis', () {
    test('Deve fazer parse de JSON com batimento_analisado como string "71 BPM"', () {
      // Arrange
      final json = {
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
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.titulo, equals('Batimento esperado ✅'));
      expect(
        analysis.interpretacao,
        contains('dentro do comportamento normal'),
      );
      expect(analysis.batimentoAnalisado, equals(71));
      expect(analysis.batimentoAnalisado, isA<int>());
    });

    test('Deve fazer parse de JSON com batimento_analisado como número', () {
      // Arrange
      final json = {
        'titulo': 'Teste',
        'interpretacao': 'Interpretação teste',
        'batimento_analisado': 85,
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.batimentoAnalisado, equals(85));
      expect(analysis.batimentoAnalisado, isA<int>());
    });

    test('Deve extrair número corretamente de string com espaços e unidade', () {
      // Arrange
      final json = {
        'titulo': 'Teste',
        'interpretacao': 'Interpretação teste',
        'batimento_analisado': '120 BPM',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.batimentoAnalisado, equals(120));
    });

    test('Deve retornar 0 quando batimento_analisado é inválido', () {
      // Arrange
      final json = {
        'titulo': 'Teste',
        'interpretacao': 'Interpretação teste',
        'batimento_analisado': 'BPM inválido',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.batimentoAnalisado, equals(0));
    });

    test('Deve usar valores padrão quando campos estão ausentes', () {
      // Arrange
      final json = {
        'batimento_analisado': '75 BPM',
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.titulo, equals('Análise Indisponível'));
      expect(
        analysis.interpretacao,
        equals('Não foi possível carregar a interpretação.'),
      );
      expect(analysis.batimentoAnalisado, equals(75));
    });

    test('Deve fazer parse de JSON com batimento_analisado como double', () {
      // Arrange
      final json = {
        'titulo': 'Teste',
        'interpretacao': 'Interpretação teste',
        'batimento_analisado': 71.5,
      };

      // Act
      final analysis = HeartbeatAnalysis.fromJson(json);

      // Assert
      expect(analysis.batimentoAnalisado, equals(71));
      expect(analysis.batimentoAnalisado, isA<int>());
    });
  });
}

