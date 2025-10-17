import 'package:http/http.dart' as http;
import 'package:PetDex/main.dart';

/// Cliente HTTP customizado que adiciona automaticamente o token de autenticação
/// em todas as requisições para a API Java
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Adiciona o token de autenticação no header Authorization
    final token = authService.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Adiciona header Content-Type se não estiver presente
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }

    print('[HttpClient] Enviando requisição: ${request.method} ${request.url}');

    try {
      final response = await _inner.send(request);

      // Se receber 401 (Unauthorized), tenta fazer novo login
      if (response.statusCode == 401) {
        print('[HttpClient] ⚠️ Token expirado (401), tentando novo login...');
        try {
          await authService.relogin();

          // Retenta a requisição com o novo token
          final newRequest = _copyRequest(request);
          final newToken = authService.getToken();
          if (newToken != null) {
            newRequest.headers['Authorization'] = 'Bearer $newToken';
          }

          print('[HttpClient] 🔄 Retentando requisição com novo token...');
          return await _inner.send(newRequest);
        } catch (e) {
          print('[HttpClient] ❌ Erro ao fazer novo login: $e');
          return response;
        }
      }

      return response;
    } catch (e) {
      print('[HttpClient] ❌ Erro ao enviar requisição: $e');
      rethrow;
    }
  }

  /// Copia uma requisição HTTP para poder retentá-la
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;
    
    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is http.StreamedRequest) {
      throw Exception('Não é possível copiar StreamedRequest');
    } else {
      throw Exception('Tipo de requisição desconhecido: $request');
    }
    
    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);
    
    return requestCopy;
  }
}

