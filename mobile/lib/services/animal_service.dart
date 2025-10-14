import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/animal.dart';
import '/models/heartbeat_data.dart';

class AnimalService {
  final String _javaApiBaseUrl = "https://petdex-api-java.onrender.com";
  final String _pythonApiBaseUrl = "https://petdex-api-python.onrender.com";

  static const String unoId = "0a1e2531-5c46-4e3e-86b1-87e07fdd16b6"; 

  Future<Animal> getAnimalInfo(String animalId) async {
    final response = await http.get(Uri.parse('$_javaApiBaseUrl/pets/$animalId'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Animal.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao carregar informações do animal.');
    }
  }

  Future<List<HeartbeatData>> getHeartbeatHistory(String animalId) async {
    final response = await http.get(Uri.parse('$_pythonApiBaseUrl/batimentos/animal/$animalId/media-ultimos-5-dias'));
    
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
      throw Exception('Falha ao carregar histórico de batimentos. Status: ${response.statusCode}');
    }
  }
}