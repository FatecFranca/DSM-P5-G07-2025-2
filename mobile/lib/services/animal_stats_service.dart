import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/models/heartbeat_data.dart';
import 'package:PetDex/services/http_client.dart';

class AnimalStatsService {

  String get _pythonApiBaseUrl => dotenv.env['API_PYTHON_URL']!;
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  // Cliente HTTP com autenticação automática para API Java
  final http.Client _httpClient = AuthenticatedHttpClient();

  /// Busca a média de batimentos dos últimos 5 dias na API Python.
  Future<List<HeartbeatData>> getMediaUltimos5Dias() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Arquivo .env não encontrado, usando valores padrão');
    }

    final endpoint = '/batimentos/media-ultimos-5-dias';
    try {
      final response = await http.get(Uri.parse('$_pythonApiBaseUrl$endpoint'));

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
        throw Exception('Falha ao carregar dados da API: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getMediaUltimos5Dias: $e');
      throw Exception('Erro de conexão ao buscar médias dos últimos 5 dias.');
    }
  }

  Future<Map<String, dynamic>?> getUltimaLocalizacaoAnimal(String idAnimal) async {
    final endpoint = '$_javaApiBaseUrl/localizacoes/animal/$idAnimal/ultima';

    try {
      // Usa o cliente HTTP autenticado para API Java
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
            'Falha ao buscar localização: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getUltimaLocalizacaoAnimal: $e');
      throw Exception('Erro ao consultar última localização do animal.');
    }
  }
}
