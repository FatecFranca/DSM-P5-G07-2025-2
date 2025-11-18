import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/services/http_client.dart';

class RaceService {
  final http.Client _client = AuthenticatedHttpClient();
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<List<Map<String, dynamic>>> fetchAllRaces(String especieId) async {
    int page = 0;
    const int size = 50;

    List<Map<String, dynamic>> all = [];

    while (true) {
      final url =
          "$_javaApiBaseUrl/racas/especie/$especieId?page=$page&size=$size&sortBy=nome&direction=asc";

      final response = await _client.get(
        Uri.parse(url),
        headers: {"accept": "application/json"},
      );

      if (response.statusCode == 401) {
        throw Exception("Token inválido ou não carregado (401).");
      }

      if (response.statusCode != 200) {
        throw Exception(
          "Erro ao buscar raças (${response.statusCode}): ${response.body}",
        );
      }

      final body = jsonDecode(response.body);

      final List content = body["content"] ?? [];

      all.addAll(
        content.map((r) => {
              "id": r["id"].toString(),
              "nome": r["nome"],
            }),
      );

      final totalPages = body["totalPages"] ?? 1;

      if (page + 1 >= totalPages) break;
      page++;
    }

    return all;
  }
}
