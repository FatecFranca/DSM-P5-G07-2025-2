import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/heartbeat_data.dart';

class AnimalStatsService {
  static const String _pythonApiBaseUrl = "https://petdex-api-python.onrender.com";

  /// Busca a média de batimentos dos últimos 5 dias na API Python.
  Future<List<HeartbeatData>> getMediaUltimos5Dias() async {
    try {
      final response = await http.get(Uri.parse('$_pythonApiBaseUrl/batimentos/media-ultimos-5-dias'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> medias = data['medias'];

        // Transforma o mapa de {data: valor} em uma lista de objetos HeartbeatData
        final List<HeartbeatData> mediasList = medias.entries.map((entry) {
          return HeartbeatData(
            date: entry.key,
            value: (entry.value as num).toDouble(),
          );
        }).toList();

        return mediasList;
      } else {
        throw Exception('Falha ao carregar os dados da API: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getMediaUltimos5Dias: $e');
      throw Exception('Erro de conexão ao buscar médias dos últimos 5 dias.');
    }
  }
}