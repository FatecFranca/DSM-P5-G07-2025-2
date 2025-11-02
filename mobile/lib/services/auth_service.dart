// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/models/auth_response.dart';
import 'package:PetDex/services/auth_storage.dart';

/// Serviço de autenticação responsável por:
/// - Fazer login com email/senha (via rota POST /auth/login)
/// - Gerenciar token de autenticação em memória
/// - Persistir dados de autenticação via AuthStorage (SharedPreferences)
class AuthService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  final AuthStorage _authStorage = AuthStorage();
  AuthResponse? _currentAuthResponse;

  /// Inicializa o storage e carrega dados persistidos (se houver)
  /// Deve ser chamado no main.dart antes de usar qualquer outro serviço.
  Future<void> init() async {
    try {
      _debug('Inicializando AuthService...');
      await _authStorage.init();

      // Carrega credenciais/response salvos (se houver)
      final saved = _authStorage.getAuthResponse();
      if (saved != null) {
        _currentAuthResponse = saved;
        _debug('Credenciais carregadas do storage. usuario=${saved.email}');
      } else {
        _debug('Nenhuma credencial salva encontrada.');
      }
    } catch (e) {
      _debug('Erro ao inicializar AuthService: $e');
      rethrow;
    }
  }

  /// Faz login com email e senha digitados pelo usuário.
  ///
  /// Retorna true quando login for bem-sucedido (status 200) e os dados forem salvos.
  /// Retorna false quando a API devolver erro (ex.: 401).
  Future<bool> login(String email, String senha) async {
    try {
      _debug('Tentando login com email: $email');

      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
        _currentAuthResponse = AuthResponse.fromJson(json);

        // Salva em storage para persistência
        await _authStorage.saveAuthData(_currentAuthResponse!);

        _debug('Login realizado com sucesso. userId=${_currentAuthResponse!.userId} animalId=${_currentAuthResponse!.animalId}');
        return true;
      } else {
        _debug('Falha no login. status=${response.statusCode} body=${response.body}');
        return false;
      }
    } catch (e) {
      _debug('Erro ao realizar login: $e');
      return false;
    }
  }

  /// Retorna o token de autenticação atual
  String? getToken() {
    return _currentAuthResponse?.token ?? _authStorage.getToken();
  }

  /// Retorna o ID do animal do usuário autenticado
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
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Realiza logout limpando os dados de autenticação
  Future<void> logout() async {
    try {
      _debug('Realizando logout...');
      _currentAuthResponse = null;
      await _authStorage.clearAuthData();
      _debug('Logout realizado com sucesso');
    } catch (e) {
      _debug('Erro ao realizar logout: $e');
      rethrow;
    }
  }

  /// Tenta "relogar" quando uma requisição recebeu 401.
  /// Neste projeto não temos refresh token — então tentamos recarregar os dados do storage.
  /// Se não houver dados persistidos, lança uma exceção para o caller decidir (ex.: forçar login).
  Future<void> relogin() async {
    try {
      _debug('Tentando relogin (recarregar dados do storage)...');
      final saved = _authStorage.getAuthResponse();
      if (saved != null && saved.token.isNotEmpty) {
        _currentAuthResponse = saved;
        _debug('Credenciais recarregadas do storage, token reaplicado.');
        return;
      }
      // Não temos como relogar automaticamente aqui
      throw Exception('Nenhum dado de login salvo para relogar.');
    } catch (e) {
      _debug('Erro em relogin: $e');
      rethrow;
    }
  }
}

void _debug(String message) {
  // evita colisão com flutter.debugPrint, mantém log simples
  print('[AuthService] $message');
}
