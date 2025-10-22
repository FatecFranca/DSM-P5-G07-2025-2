import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/models/latest_heartbeat.dart';
import 'package:PetDex/services/http_client.dart';
import 'package:PetDex/models/checkup_result.dart';
import 'dart:async';

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
    // Usa o cliente HTTP autenticado para API Python
    final response = await _httpClient.get(
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

  // POST /ia/checkup/animal/{idAnimal}
  Future<CheckupResult> postCheckup(String animalId, Map<String, dynamic> sintomas) async {
    final url = Uri.parse("$_pythonApiBaseUrl/ia/checkup/animal/$animalId");

    try {
      final response = await _httpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(sintomas),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return CheckupResult.fromJson(decoded);
      } else {
        throw Exception(
          'Erro ao realizar checkup: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Tempo de requisição excedido (timeout).');
    } catch (e) {
      throw Exception('Erro inesperado ao realizar checkup: $e');
    }
  }
}
