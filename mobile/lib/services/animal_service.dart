import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/models/latest_heartbeat.dart';
import 'package:PetDex/services/http_client.dart';

class AnimalService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;
  String get _pythonApiBaseUrl => dotenv.env['API_PYTHON_URL']!;

  // Cliente HTTP com autenticação automática
  final http.Client _httpClient = AuthenticatedHttpClient();

  Future<Animal> getAnimalInfo(String animalId) async {
    print(animalId);
    // Usa o cliente HTTP autenticado
    final response = await _httpClient.get(
      Uri.parse('$_javaApiBaseUrl/animais/$animalId'),
    );
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      print(decodedBody);
      return Animal.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao carregar informações do animal.');
    }
  }

  Future<LatestHeartbeat> getLatestHeartbeat(String animalId) async {
    // Usa o cliente HTTP autenticado
    final response = await _httpClient.get(Uri.parse('$_javaApiBaseUrl/batimentos/animal/$animalId/ultimo'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return LatestHeartbeat.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao carregar o último batimento. Status: ${response.statusCode}');
    }
  }

  Future<List<HeartbeatData>> getHeartbeatHistory(String animalId) async {
    // Usa cliente HTTP padrão para API Python (não requer autenticação)
    final response = await http.get(
      Uri.parse(
        '$_pythonApiBaseUrl/batimentos/animal/$animalId/media-ultimos-5-dias',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> medias = data['medias'];
      final List<HeartbeatData> mediasList = medias.entries.map((entry) {
        return HeartbeatData(
          date: entry.key,
          value: (entry.value as num).toDouble(),
        );
      }).toList();
      mediasList.sort((a, b) => a.date.compareTo(b.date));
      return mediasList;
    } else {
      throw Exception(
        'Falha ao carregar histórico de batimentos. Status: ${response.statusCode}',
      );
    }
  }
}
