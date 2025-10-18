import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PetDex/models/auth_response.dart';

/// Serviço para armazenar e recuperar dados de autenticação de forma persistente
/// Utiliza SharedPreferences para persistência local
class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _animalIdKey = 'auth_animal_id';
  static const String _nomeKey = 'auth_nome';
  static const String _emailKey = 'auth_email';
  static const String _petNameKey = 'auth_pet_name';
  static const String _authResponseKey = 'auth_response';

  late SharedPreferences _prefs;

  /// Inicializa o serviço de armazenamento
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva os dados de autenticação de forma persistente
  Future<void> saveAuthData(AuthResponse authResponse) async {
    try {
      // Salva cada campo individualmente para fácil acesso
      await _prefs.setString(_tokenKey, authResponse.token);
      await _prefs.setString(_userIdKey, authResponse.userId);
      await _prefs.setString(_nomeKey, authResponse.nome);
      await _prefs.setString(_emailKey, authResponse.email);

      // Salva o animalId se disponível
      if (authResponse.animalId != null) {
        await _prefs.setString(_animalIdKey, authResponse.animalId!);
      }

      // Salva o petName se disponível
      if (authResponse.petName != null) {
        await _prefs.setString(_petNameKey, authResponse.petName!);
      }

      // Salva a resposta completa em JSON para referência
      await _prefs.setString(_authResponseKey, jsonEncode(authResponse.toJson()));

      debugPrint('✅ Dados de autenticação salvos com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao salvar dados de autenticação: $e');
      rethrow;
    }
  }

  /// Recupera o token de autenticação armazenado
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Recupera o ID do usuário armazenado
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Recupera o ID do animal armazenado
  String? getAnimalId() {
    return _prefs.getString(_animalIdKey);
  }

  /// Recupera o nome do usuário armazenado
  String? getNome() {
    return _prefs.getString(_nomeKey);
  }

  /// Recupera o email do usuário armazenado
  String? getEmail() {
    return _prefs.getString(_emailKey);
  }

  /// Recupera o nome do pet armazenado
  String? getPetName() {
    return _prefs.getString(_petNameKey);
  }

  /// Recupera a resposta de autenticação completa
  AuthResponse? getAuthResponse() {
    final jsonString = _prefs.getString(_authResponseKey);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthResponse.fromJson(json);
    } catch (e) {
      debugPrint('❌ Erro ao recuperar resposta de autenticação: $e');
      return null;
    }
  }

  /// Verifica se existe um token válido armazenado
  bool hasValidToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Limpa todos os dados de autenticação armazenados
  Future<void> clearAuthData() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_animalIdKey);
      await _prefs.remove(_nomeKey);
      await _prefs.remove(_emailKey);
      await _prefs.remove(_petNameKey);
      await _prefs.remove(_authResponseKey);

      debugPrint('✅ Dados de autenticação limpos com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados de autenticação: $e');
      rethrow;
    }
  }
}

// Função auxiliar para debug
void debugPrint(String message) {
  print('[AuthStorage] $message');
}

