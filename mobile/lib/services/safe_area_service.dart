import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/services/http_client.dart';

/// Modelo para representar uma área segura
class SafeArea {
  final String id;
  final double raio;
  final double latitude;
  final double longitude;
  final String animal;

  SafeArea({
    required this.id,
    required this.raio,
    required this.latitude,
    required this.longitude,
    required this.animal,
  });

  factory SafeArea.fromJson(Map<String, dynamic> json) {
    return SafeArea(
      id: json['id'],
      raio: (json['raio'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      animal: json['animal'],
    );
  }
}

class SafeAreaService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  // Cliente HTTP com autenticação automática
  final http.Client _httpClient = AuthenticatedHttpClient();

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

      print('[SafeAreaService] 📍 Criando área segura...');
      print('[SafeAreaService] Endpoint: $endpoint');
      print('[SafeAreaService] Body: $body');

      // Usa o cliente HTTP autenticado
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('[SafeAreaService] Status: ${response.statusCode}');
      print('[SafeAreaService] Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[SafeAreaService] ✅ Área segura criada com sucesso!');
        return true;
      } else {
        throw Exception(
          'Falha ao criar área segura: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('[SafeAreaService] ❌ Erro ao criar área segura: $e');
      throw Exception('Erro ao criar área segura: $e');
    }
  }

  /// Busca a área segura de um animal
  ///
  /// Parâmetros:
  /// - [animalId]: ID do animal
  ///
  /// Retorna a área segura do animal ou null se não existir
  Future<SafeArea?> getSafeAreaByAnimalId(String animalId) async {
    final endpoint = '$_javaApiBaseUrl/areas-seguras/animal/$animalId';

    try {
      print('[SafeAreaService] 🔍 Buscando área segura do animal: $animalId');
      print('[SafeAreaService] Endpoint: $endpoint');

      // Usa o cliente HTTP autenticado
      final response = await _httpClient.get(Uri.parse(endpoint));

      print('[SafeAreaService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('[SafeAreaService] ✅ Área segura encontrada!');
        print('[SafeAreaService] Dados: $data');
        return SafeArea.fromJson(data);
      } else if (response.statusCode == 404) {
        print('[SafeAreaService] ⚠️ Área segura não encontrada para o animal');
        return null;
      } else {
        throw Exception(
          'Falha ao buscar área segura: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('[SafeAreaService] ❌ Erro ao buscar área segura: $e');
      return null;
    }
  }
}

