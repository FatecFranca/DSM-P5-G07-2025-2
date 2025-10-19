import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:PetDex/services/animal_stats_service.dart';

class MapServices {
  /// 🔍 Consulta o endereço atual do animal usando a localização retornada pela API do PetDex
  static Future<void> getEnderecoAtualDoAnimal(String idAnimal) async {
    try {
      final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

      if (googleMapsApiKey.isEmpty) {
        return;
      }

      final local = await AnimalStatsService().getUltimaLocalizacaoAnimal(idAnimal);

      if (local == null) {
        return;
      }

      final latitude = local['latitude'];
      final longitude = local['longitude'];

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey&language=pt-BR';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Address retrieved successfully
        }
      }
    } catch (e) {
      // Error handled silently
    }
  }

  /// 🗺️ Monta o mapa com base na localização atual do animal
  static Future<void> montarMapa(String idAnimal) async {
    try {
      final local = await AnimalStatsService().getUltimaLocalizacaoAnimal(idAnimal);

      if (local == null) {
        return;
      }

      // Map data retrieved successfully
    } catch (e) {
      // Error handled silently
    }
  }
}
