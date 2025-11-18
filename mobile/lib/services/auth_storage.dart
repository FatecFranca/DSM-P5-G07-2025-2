import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PetDex/models/auth_response.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _animalIdKey = 'auth_animal_id';
  static const String _nomeKey = 'auth_nome';
  static const String _emailKey = 'auth_email';
  static const String _petNameKey = 'auth_pet_name';
  static const String _authResponseKey = 'auth_response';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveAuthData(AuthResponse authResponse) async {
    try {
      await _prefs.setString(_tokenKey, authResponse.token);
      await _prefs.setString(_userIdKey, authResponse.userId);
      await _prefs.setString(_nomeKey, authResponse.nome);
      await _prefs.setString(_emailKey, authResponse.email);
      if (authResponse.animalId != null) {
        await _prefs.setString(_animalIdKey, authResponse.animalId!);
      }
      if (authResponse.petName != null) {
        await _prefs.setString(_petNameKey, authResponse.petName!);
      }
      await _prefs.setString(_authResponseKey, jsonEncode(authResponse.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  /// 🔄 Atualiza apenas o animalId armazenado
  Future<void> updateAnimalId(String animalId) async {
    await _prefs.setString(_animalIdKey, animalId);
    final jsonString = _prefs.getString(_authResponseKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        json['animalId'] = animalId;
        await _prefs.setString(_authResponseKey, jsonEncode(json));
      } catch (e) {
        print('[AuthStorage] Falha ao atualizar animalId no JSON: $e');
      }
    }
  }

  String? getToken() => _prefs.getString(_tokenKey);
  String? getUserId() => _prefs.getString(_userIdKey);
  String? getAnimalId() => _prefs.getString(_animalIdKey);
  String? getNome() => _prefs.getString(_nomeKey);
  String? getEmail() => _prefs.getString(_emailKey);
  String? getPetName() => _prefs.getString(_petNameKey);

  AuthResponse? getAuthResponse() {
    final jsonString = _prefs.getString(_authResponseKey);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  bool hasValidToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_animalIdKey);
    await _prefs.remove(_nomeKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_petNameKey);
    await _prefs.remove(_authResponseKey);
  }
}

void debugPrint(String message) {
  print('[AuthStorage] $message');
}
