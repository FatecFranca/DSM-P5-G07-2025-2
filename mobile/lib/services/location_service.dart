import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/services/http_client.dart';
import 'package:PetDex/services/safe_area_service.dart';

class LocationService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  // Cliente HTTP com autenticação automática
  final http.Client _httpClient = AuthenticatedHttpClient();

  Future<LocationData?> getUltimaLocalizacaoAnimal(String idAnimal) async {
    final endpoint = '$_javaApiBaseUrl/localizacoes/animal/$idAnimal/ultima';

    try {
      // Usa o cliente HTTP autenticado
      final response = await _httpClient.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationData.fromJson(data);
      } else {
        throw Exception(
            'Falha ao buscar localização: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao consultar última localização do animal: $e');
    }
  }

  Future<String?> getEnderecoFromCoordinates(double latitude, double longitude, String googleMapsApiKey) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey&language=pt-BR';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter endereço: $e');
    }
  }

  /// Busca a área segura do animal
  /// Retorna a área segura ou null se não existir
  Future<SafeArea?> getSafeArea(String animalId) async {
    final safeAreaService = SafeAreaService();
    return await safeAreaService.getSafeAreaByAnimalId(animalId);
  }
}
