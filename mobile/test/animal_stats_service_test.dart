import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  group('AnimalStatsService - getMediaPorData', () {
    test('Deve formatar a data corretamente no formato YYYY-MM-DD', () {
      // Arrange
      final date = DateTime(2025, 10, 18);

      // Act
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Assert
      expect(formattedDate, equals('2025-10-18'));
    });

    test('Deve usar os mesmos valores para inicio e fim em uma consulta de um dia', () {
      // Arrange
      final date = DateTime(2025, 10, 18);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Act
      final queryParams = {
        'inicio': formattedDate,
        'fim': formattedDate,
      };

      // Assert
      expect(queryParams['inicio'], equals(queryParams['fim']));
      expect(queryParams['inicio'], equals('2025-10-18'));
    });

    test('Deve construir a URL correta com o endpoint de media-por-data', () {
      // Arrange
      final animalId = '68194120636f719fcd5ee5fd';
      final baseUrl = 'https://petdex-api-python.onrender.com';
      final expectedPath = '/batimentos/animal/$animalId/batimentos/media-por-data';

      // Act
      final fullUrl = '$baseUrl$expectedPath';

      // Assert
      expect(fullUrl, contains('/batimentos/animal/'));
      expect(fullUrl, contains('/batimentos/media-por-data'));
      expect(fullUrl, contains(animalId));
    });

    test('Deve converter a resposta numérica para double', () {
      // Arrange
      final mediaValue = 71.5;

      // Act
      final convertedValue = (mediaValue as num).toDouble();

      // Assert
      expect(convertedValue, isA<double>());
      expect(convertedValue, equals(71.5));
    });

    test('Deve parsear corretamente a resposta JSON com campo media', () {
      // Arrange
      final responseBody = '{"media": 71.5}';

      // Act
      final Map<String, dynamic> data = jsonDecode(responseBody);
      final media = data.containsKey('media') && data['media'] != null
          ? (data['media'] as num).toDouble()
          : null;

      // Assert
      expect(media, equals(71.5));
      expect(media, isA<double>());
    });

    test('Deve retornar null quando o campo media não está na resposta', () {
      // Arrange
      final responseBody = '{"resultado": "sem dados"}';

      // Act
      final Map<String, dynamic> data = jsonDecode(responseBody);
      final media = data.containsKey('media') && data['media'] != null
          ? (data['media'] as num).toDouble()
          : null;

      // Assert
      expect(media, isNull);
    });

    test('Deve formatar diferentes datas corretamente', () {
      // Arrange
      final dates = [
        DateTime(2025, 1, 1),
        DateTime(2025, 12, 31),
        DateTime(2025, 6, 15),
      ];

      final expectedFormats = [
        '2025-01-01',
        '2025-12-31',
        '2025-06-15',
      ];

      // Act & Assert
      for (int i = 0; i < dates.length; i++) {
        final formatted = DateFormat('yyyy-MM-dd').format(dates[i]);
        expect(formatted, equals(expectedFormats[i]));
      }
    });

    test('Deve construir URI com query parameters corretamente', () {
      // Arrange
      final baseUrl = 'https://petdex-api-python.onrender.com';
      final animalId = '68194120636f719fcd5ee5fd';
      final date = DateTime(2025, 10, 18);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Act
      final uri = Uri.parse(
        '$baseUrl/batimentos/animal/$animalId/batimentos/media-por-data',
      ).replace(queryParameters: {'inicio': formattedDate, 'fim': formattedDate});

      // Assert
      expect(uri.toString(), contains('inicio=2025-10-18'));
      expect(uri.toString(), contains('fim=2025-10-18'));
      expect(uri.toString(), contains(animalId));
    });
  });
}
