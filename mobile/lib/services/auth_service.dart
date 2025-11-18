import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:PetDex/models/auth_response.dart';
import 'package:PetDex/services/auth_storage.dart';

class AuthService {
  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;
  final AuthStorage _authStorage = AuthStorage();
  AuthResponse? _currentAuthResponse;

  Future<void> init() async {
    try {
      debugPrint('Inicializando AuthService...');
      await _authStorage.init();
      final saved = _authStorage.getAuthResponse();
      if (saved != null) {
        _currentAuthResponse = saved;
        debugPrint('Credenciais carregadas do storage. usuario=${saved.email}');
      } else {
        debugPrint('Nenhuma credencial salva encontrada.');
      }
    } catch (e) {
      debugPrint('Erro ao inicializar AuthService: $e');
      rethrow;
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      debugPrint('‼️‼️‼️‼️Tentando login com email: $email');
      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        _currentAuthResponse = AuthResponse.fromJson(json);
        await _authStorage.saveAuthData(_currentAuthResponse!);
        debugPrint(
            'Login realizado com sucesso. userId=${_currentAuthResponse!.userId} animalId=${_currentAuthResponse!.animalId}');
        return true;
      } else {
        debugPrint(
            'Falha no login. status=${response.statusCode} body=${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao realizar login: $e');
      return false;
    }
  }

  /// 🔄 Atualiza o animalId localmente e no backend
  Future<void> setAnimalId(String animalId) async {
    try {
      debugPrint('Atualizando animalId localmente para $animalId...');
      if (_currentAuthResponse != null) {
        _currentAuthResponse =
            _currentAuthResponse!.copyWith(animalId: animalId);
      }
      await _authStorage.updateAnimalId(animalId);
      debugPrint('animalId atualizado com sucesso no storage e em memória.');
    } catch (e) {
      debugPrint('Erro ao atualizar animalId: $e');
    }
  }

  /// 🔗 Atualiza o usuário na API Java com o novo animal vinculado
  Future<void> updateUserWithAnimal(String userId, String animalId) async {
    try {
      final url = Uri.parse('$_javaApiBaseUrl/usuarios/$userId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_currentAuthResponse?.token}',
        },
        body: jsonEncode({'animalId': animalId}),
      );

      if (response.statusCode == 200) {
        debugPrint('Usuário atualizado com o animalId na API com sucesso.');
        await setAnimalId(animalId);
      } else {
        debugPrint(
            'Falha ao atualizar o usuário na API: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar usuário com animalId: $e');
    }
  }

  String? getToken() => _currentAuthResponse?.token ?? _authStorage.getToken();
  String? getAnimalId() =>
      _currentAuthResponse?.animalId ?? _authStorage.getAnimalId();
  String? getUserId() =>
      _currentAuthResponse?.userId ?? _authStorage.getUserId();
  String? getNome() => _currentAuthResponse?.nome ?? _authStorage.getNome();
  String? getEmail() => _currentAuthResponse?.email ?? _authStorage.getEmail();
  String? getPetName() =>
      _currentAuthResponse?.petName ?? _authStorage.getPetName();
  AuthResponse? getAuthResponse() =>
      _currentAuthResponse ?? _authStorage.getAuthResponse();

  bool isAuthenticated() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      debugPrint('Realizando logout...');
      _currentAuthResponse = null;
      await _authStorage.clearAuthData();
      debugPrint('Logout realizado com sucesso');
    } catch (e) {
      debugPrint('Erro ao realizar logout: $e');
      rethrow;
    }
  }

  Future<void> relogin() async {
    try {
      debugPrint('Tentando relogin...');
      final saved = _authStorage.getAuthResponse();
      if (saved != null && saved.token.isNotEmpty) {
        _currentAuthResponse = saved;
        debugPrint('Credenciais recarregadas do storage.');
        return;
      }
      throw Exception('Nenhum dado de login salvo para relogar.');
    } catch (e) {
      debugPrint('Erro em relogin: $e');
      rethrow;
    }
  }
}

void debugPrint(String message) {
  print('[AuthService] $message');
}
