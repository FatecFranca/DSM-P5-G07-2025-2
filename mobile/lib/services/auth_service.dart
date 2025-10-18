import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/models/auth_response.dart';
import 'package:PetDex/services/auth_storage.dart';

/// Serviço de autenticação responsável por:
/// - Realizar login automático com credenciais do .env
/// - Gerenciar token de autenticação
/// - Fornecer token para requisições HTTP
class AuthService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;
  
  final AuthStorage _authStorage = AuthStorage();
  AuthResponse? _currentAuthResponse;

  /// Inicializa o serviço de autenticação
  /// Deve ser chamado no main.dart antes de usar qualquer outro serviço
  /// SEMPRE realiza login ao reiniciar o app para garantir token válido
  Future<void> init() async {
    try {
      debugPrint('🔐 Inicializando AuthService...');

      // Inicializa o armazenamento
      await _authStorage.init();

      // SEMPRE realiza login ao reiniciar o app para garantir token válido
      debugPrint('🔄 Realizando login automático ao iniciar o app...');
      await _performAutoLogin();

    } catch (e) {
      debugPrint('❌ Erro ao inicializar AuthService: $e');
      rethrow;
    }
  }

  /// Realiza login automático usando credenciais do .env
  Future<void> _performAutoLogin() async {
    try {
      final email = dotenv.env['LOGIN_EMAIL'];
      final senha = dotenv.env['LOGIN_SENHA'];
      
      if (email == null || email.isEmpty || senha == null || senha.isEmpty) {
        throw Exception('Credenciais de login não configuradas no .env');
      }
      
      debugPrint('🔑 Tentando login com email: $email');
      
      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _currentAuthResponse = AuthResponse.fromJson(json);

        // Salva os dados de autenticação
        await _authStorage.saveAuthData(_currentAuthResponse!);

        debugPrint('✅ Login automático realizado com sucesso');
        debugPrint('👤 Usuário: ${_currentAuthResponse!.nome}');
        debugPrint('🐾 Animal ID: ${_currentAuthResponse!.animalId}');
        debugPrint('🔑 Token: ${_currentAuthResponse!.token.substring(0, 20)}...');
      } else {
        throw Exception(
          'Falha no login automático. Status: ${response.statusCode}. '
          'Resposta: ${response.body}'
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao realizar login automático: $e');
      rethrow;
    }
  }

  /// Retorna o token de autenticação atual
  /// Deve ser usado em todas as requisições HTTP
  String? getToken() {
    final token = _currentAuthResponse?.token ?? _authStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ getToken() retornou null ou vazio!');
      debugPrint('_currentAuthResponse: $_currentAuthResponse');
      debugPrint('_authStorage.getToken(): ${_authStorage.getToken()}');
    }
    return token;
  }

  /// Retorna o ID do animal do usuário autenticado
  /// Deve ser usado em rotas que requerem o ID do animal
  String? getAnimalId() {
    return _currentAuthResponse?.animalId ?? _authStorage.getAnimalId();
  }

  /// Retorna o ID do usuário autenticado
  String? getUserId() {
    return _currentAuthResponse?.userId ?? _authStorage.getUserId();
  }

  /// Retorna o nome do usuário autenticado
  String? getNome() {
    return _currentAuthResponse?.nome ?? _authStorage.getNome();
  }

  /// Retorna o email do usuário autenticado
  String? getEmail() {
    return _currentAuthResponse?.email ?? _authStorage.getEmail();
  }

  /// Retorna o nome do pet autenticado
  String? getPetName() {
    return _currentAuthResponse?.petName ?? _authStorage.getPetName();
  }

  /// Retorna a resposta de autenticação completa
  AuthResponse? getAuthResponse() {
    return _currentAuthResponse ?? _authStorage.getAuthResponse();
  }

  /// Verifica se o usuário está autenticado
  bool isAuthenticated() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  /// Realiza logout limpando os dados de autenticação
  Future<void> logout() async {
    try {
      debugPrint('🚪 Realizando logout...');
      _currentAuthResponse = null;
      await _authStorage.clearAuthData();
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao realizar logout: $e');
      rethrow;
    }
  }

  /// Realiza novo login (útil para refresh de token)
  Future<void> relogin() async {
    try {
      debugPrint('🔄 Realizando novo login...');
      _currentAuthResponse = null;
      await _authStorage.clearAuthData();
      await _performAutoLogin();
    } catch (e) {
      debugPrint('❌ Erro ao realizar novo login: $e');
      rethrow;
    }
  }
}

// Função auxiliar para debug
void debugPrint(String message) {
  print('[AuthService] $message');
}

