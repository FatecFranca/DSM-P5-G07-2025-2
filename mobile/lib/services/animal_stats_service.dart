import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/heartbeat_data.dart';

class AnimalStatsService {

  static const String _pythonApiBaseUrl = "https://petdex-api-python.onrender.com";
  static const String _javaApiBaseUrl = "https://petdex-api-java.onrender.com";

  /// Busca a média de batimentos dos últimos 5 dias na API Python.
  Future<List<HeartbeatData>> getMediaUltimos5Dias() async {
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

  Future<Map<String, double>?> getUltimaLocalizacaoAnimal(String idAnimal) async {
    final endpoint =
        '$_javaApiBaseUrl/localizacoes/animal/$idAnimal?page=0&size=1';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Verifica se existe conteúdo na resposta (padrão Spring Page)
        if (data.containsKey('content') &&
            data['content'] is List &&
            data['content'].isNotEmpty) {
          final ultimo = data['content'][0];

          return {
            'latitude': double.tryParse(ultimo['latitude'].toString()) ?? 0.0,
            'longitude': double.tryParse(ultimo['longitude'].toString()) ?? 0.0,
          };
        } else {
          print('Nenhuma localização encontrada para o animal $idAnimal');
          return null;
        }
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
