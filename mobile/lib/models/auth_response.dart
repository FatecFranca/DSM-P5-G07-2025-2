/// Modelo para a resposta de autenticação da API
/// Contém o token JWT e informações do usuário autenticado
class AuthResponse {
  final String token;
  final String? animalId;
  final String userId;
  final String nome;
  final String email;

  AuthResponse({
    required this.token,
    this.animalId,
    required this.userId,
    required this.nome,
    required this.email,
  });

  /// Factory para criar AuthResponse a partir de JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      animalId: json['animalId'] as String?,
      userId: json['userId'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }

  /// Converte AuthResponse para JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'animalId': animalId,
      'userId': userId,
      'nome': nome,
      'email': email,
    };
  }
}

