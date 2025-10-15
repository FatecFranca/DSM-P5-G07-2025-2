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
        print('❌ ERRO: GOOGLE_MAPS_API_KEY não encontrada no .env!');
        return;
      }

      final local = await AnimalStatsService().getUltimaLocalizacaoAnimal(idAnimal);

      if (local == null) {
        print('⚠️ Nenhuma localização encontrada para o animal $idAnimal');
        return;
      }

      final latitude = local['latitude'];
      final longitude = local['longitude'];
      print('📍 Coordenadas obtidas: $latitude, $longitude');

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey&language=pt-BR';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final endereco = data['results'][0]['formatted_address'];
          print('🏠 Endereço atual do animal: $endereco');
        } else {
          print('⚠️ Nenhum endereço encontrado para essas coordenadas.');
        }
      } else {
        print('❌ Erro HTTP ${response.statusCode} ao consultar o Google Maps.');
      }
    } catch (e) {
      print('❌ Erro ao obter endereço do animal: $e');
    }
  }

  /// 🗺️ Monta o mapa com base na localização atual do animal
  static Future<void> montarMapa(String idAnimal) async {
    try {
      final local = await AnimalStatsService().getUltimaLocalizacaoAnimal(idAnimal);

      if (local == null) {
        print('⚠️ Nenhuma localização válida encontrada para o animal.');
        return;
      }

      final latitude = local['latitude'];
      final longitude = local['longitude'];

      print('🗺️ Mapa montado com a localização: ($latitude, $longitude)');
      print('✅ Use esses dados para renderizar o mapa do Google Maps.');
    } catch (e) {
      print('❌ Erro ao montar o mapa: $e');
    }
  }
}
