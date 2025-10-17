import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/models/latest_heartbeat.dart';

class AnimalService {
  final String _javaApiBaseUrl = "https://petdex-api-java.onrender.com";
  final String _pythonApiBaseUrl = "https://petdex-api-python.onrender.com";

  static const String unoId = "68194120636f719fcd5ee5fd";

  Future<Animal> getAnimalInfo(String animalId) async {
    print(animalId);
    final response = await http.get(
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
    final response = await http.get(Uri.parse('$_javaApiBaseUrl/batimentos/animal/$animalId/ultimo'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return LatestHeartbeat.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao carregar o último batimento. Status: ${response.statusCode}');
    }
  }

  Future<List<HeartbeatData>> getHeartbeatHistory(String animalId) async {
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
