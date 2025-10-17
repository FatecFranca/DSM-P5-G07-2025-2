import 'dart:convert';
import 'package:http/http.dart' as http;

class SafeAreaService {
  static const String _javaApiBaseUrl = "https://petdex-api-java.onrender.com";

  /// Cria uma nova área segura para o animal
  /// 
  /// Parâmetros:
  /// - [raio]: Raio da área segura em metros
  /// - [latitude]: Latitude do centro da área segura
  /// - [longitude]: Longitude do centro da área segura
  /// - [animalId]: ID do animal
  /// 
  /// Retorna true se a área foi criada com sucesso, false caso contrário
  Future<bool> createSafeArea({
    required double raio,
    required double latitude,
    required double longitude,
    required String animalId,
  }) async {
    final endpoint = '$_javaApiBaseUrl/areas-seguras';

    try {
      final body = jsonEncode({
        'raio': raio,
        'latitude': latitude,
        'longitude': longitude,
        'animal': animalId,
      });

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Falha ao criar área segura: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao criar área segura: $e');
    }
  }
}

