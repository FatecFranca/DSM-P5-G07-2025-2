import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PetDex/models/location_model.dart';

class LocationService {
  static const String _javaApiBaseUrl = "https://petdex-api-java.onrender.com";

  Future<LocationData?> getUltimaLocalizacaoAnimal(String idAnimal) async {
    final endpoint = '$_javaApiBaseUrl/localizacoes/animal/$idAnimal/ultima';

    try {
      final response = await http.get(Uri.parse(endpoint));

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
}
