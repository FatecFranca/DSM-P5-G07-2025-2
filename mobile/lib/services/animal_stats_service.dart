import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '/models/heartbeat_analysis.dart';
import '/models/heartbeat_data.dart';
import '/services/http_client.dart';
import 'package:flutter/material.dart';

class AnimalStatsService {
  String get _pythonApiBaseUrl => dotenv.env['API_PYTHON_URL']!;
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  // Cliente HTTP com autenticação automática
  final http.Client _httpClient = AuthenticatedHttpClient();

  /// Busca a média de batimentos dos últimos 5 dias na API Python.
  Future<List<HeartbeatData>> getMediaUltimos5Dias(String animalId) async {
    // CORREÇÃO: O endpoint correto precisa do ID do animal.
    final endpoint = '/batimentos/animal/$animalId/media-ultimos-5-dias';
    try {
      final response = await _httpClient.get(Uri.parse('$_pythonApiBaseUrl$endpoint'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> medias = data['medias'];

        final List<HeartbeatData> mediasList = medias.entries.map((entry) {
          return HeartbeatData(
            date: entry.key,
            value: (entry.value as num).toDouble(),
          );
        }).toList();

        return mediasList;
      } else {
        throw Exception(
          'Falha ao carregar dados da API: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro em getMediaUltimos5Dias: $e');
      throw Exception('Erro de conexão ao buscar médias dos últimos 5 dias.');
    }
  }

  Future<Map<String, dynamic>?> getUltimaLocalizacaoAnimal(
    String idAnimal,
  ) async {
    final endpoint = '$_javaApiBaseUrl/localizacoes/animal/$idAnimal/ultima';

    try {
      final response = await _httpClient.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return {
          'id': data['id'],
          'data': data['data'],
          'latitude': (data['latitude'] as num).toDouble(),
          'longitude': (data['longitude'] as num).toDouble(),
          'animal': data['animal'],
          'coleira': data['coleira'],
          'isOutsideSafeZone': data['isOutsideSafeZone'],
          'distanciaDoPerimetro': data['distanciaDoPerimetro'] != null
              ? (data['distanciaDoPerimetro'] as num).toDouble()
              : null
        };
      } else {
        throw Exception(
          'Falha ao buscar localização: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro em getUltimaLocalizacaoAnimal: $e');
      throw Exception('Erro ao consultar última localização do animal.');
    }
  }

  Future<double?> getMediaPorData(String animalId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Endpoint correto com /batimentos/ duplicado conforme especificação da API
    final uri = Uri.parse(
      '$_pythonApiBaseUrl/batimentos/animal/$animalId/batimentos/media-por-data',
    ).replace(queryParameters: {'inicio': formattedDate, 'fim': formattedDate});

    try {
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('media') && data['media'] != null) {
          final media = (data['media'] as num).toDouble();
          return media;
        }
        return null;
      } else {
        throw Exception(
          'Falha ao carregar dados da API: Status ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Erro em getMediaPorData: $e');
      throw Exception('Erro de conexão ao buscar média por data.');
    }
  }

  /// Busca a análise do último batimento cardíaco na API Python.
  Future<HeartbeatAnalysis> getLatestHeartbeatAnalysis(String animalId) async {
    final endpoint = '/batimentos/animal/$animalId/ultimo/analise';
    
    try {
      final response = await _httpClient.get(
        Uri.parse('$_pythonApiBaseUrl$endpoint'),
      );

      if (response.statusCode == 200) {
        return HeartbeatAnalysis.fromJson(jsonDecode(response.body));
      } else {
        if (response.statusCode == 401) {
          throw Exception('Falha na autenticação (401). Token JWT pode ser inválido ou expirado.');
        }
        throw Exception('Falha ao carregar análise da API: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getLatestHeartbeatAnalysis: $e');
      throw Exception('Erro de conexão ao buscar análise de batimentos.');
    }
  }

  /// Busca a média de batimentos cardíacos das últimas 5 horas do animal.
Future<List<HeartbeatData>> getMediaUltimas5HorasRegistradas(String animalId) async {
  final endpoint = '/batimentos/animal/$animalId/media-ultimas-5-horas-registradas';
  
  try {
    final response = await _httpClient.get(Uri.parse('$_pythonApiBaseUrl$endpoint'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // A API retorna {"media": 72, "media_por_hora": { ... }}
      if (!data.containsKey('media_por_hora')) {
        throw Exception('Resposta inesperada da API: campo "media_por_hora" ausente.');
      }

      final Map<String, dynamic> mediasPorHora = data['media_por_hora'];

      final List<HeartbeatData> lista = mediasPorHora.entries.map((entry) {
        return HeartbeatData(
          date: entry.key,
          value: (entry.value as num).toDouble(),
        );
      }).toList();

      // Ordenar por data/hora para exibição correta no gráfico
      lista.sort((a, b) => a.date.compareTo(b.date));

      return lista;
    } else {
      throw Exception(
        'Falha ao carregar dados da API: Status ${response.statusCode}, Body: ${response.body}',
      );
    }
  } catch (e) {
    print('Erro em getMediaUltimas5HorasRegistradas: $e');
    throw Exception('Erro de conexão ao buscar médias das últimas 5 horas.');
  }
}
}