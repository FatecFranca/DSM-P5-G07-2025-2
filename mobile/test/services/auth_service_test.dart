import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/models/auth_response.dart';

void main() {
  group('AuthResponse', () {
    test('Deve criar AuthResponse com todos os campos', () {
      final authResponse = AuthResponse(
        token: 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiI2OGYwMWIxMmE3Y2RjZTY0YWJhZjNjMTciLCJlbWFpbCI6Imdyc3BpcmxhbmRlbGxpQGdtYWlsLmNvbSIsInN1YiI6IjY4ZjAxYjEyYTdjZGNlNjRhYmFmM2MxNyIsImlhdCI6MTc2MDcxODQzM30.8KpbeS9AyGk5J_zOmERkddKBaTHI5L7BJaQpiHxwegk',
        animalId: '68194120636f719fcd5ee5fd',
        userId: '68f01b12a7cdce64abaf3c17',
        nome: 'Gabriel',
        email: 'grspirlandelli@gmail.com',
        petName: 'Uno',
      );

      expect(authResponse.token, isNotEmpty);
      expect(authResponse.animalId, '68194120636f719fcd5ee5fd');
      expect(authResponse.userId, '68f01b12a7cdce64abaf3c17');
      expect(authResponse.nome, 'Gabriel');
      expect(authResponse.email, 'grspirlandelli@gmail.com');
      expect(authResponse.petName, 'Uno');
    });

    test('Deve fazer parse de JSON com todos os campos', () {
      final json = {
        'token': 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiI2OGYwMWIxMmE3Y2RjZTY0YWJhZjNjMTciLCJlbWFpbCI6Imdyc3BpcmxhbmRlbGxpQGdtYWlsLmNvbSIsInN1YiI6IjY4ZjAxYjEyYTdjZGNlNjRhYmFmM2MxNyIsImlhdCI6MTc2MDcxODQzM30.8KpbeS9AyGk5J_zOmERkddKBaTHI5L7BJaQpiHxwegk',
        'animalId': '68194120636f719fcd5ee5fd',
        'userId': '68f01b12a7cdce64abaf3c17',
        'nome': 'Gabriel',
        'email': 'grspirlandelli@gmail.com',
        'petName': 'Uno',
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.token, isNotEmpty);
      expect(authResponse.animalId, '68194120636f719fcd5ee5fd');
      expect(authResponse.userId, '68f01b12a7cdce64abaf3c17');
      expect(authResponse.nome, 'Gabriel');
      expect(authResponse.email, 'grspirlandelli@gmail.com');
      expect(authResponse.petName, 'Uno');
    });

    test('Deve fazer parse de JSON com animalId nulo', () {
      final json = {
        'token': 'token-teste',
        'animalId': null,
        'userId': '68f01b12a7cdce64abaf3c17',
        'nome': 'Gabriel',
        'email': 'grspirlandelli@gmail.com',
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.token, 'token-teste');
      expect(authResponse.animalId, null);
      expect(authResponse.userId, '68f01b12a7cdce64abaf3c17');
    });

    test('Deve converter AuthResponse para JSON', () {
      final authResponse = AuthResponse(
        token: 'token-teste',
        animalId: '68194120636f719fcd5ee5fd',
        userId: '68f01b12a7cdce64abaf3c17',
        nome: 'Gabriel',
        email: 'grspirlandelli@gmail.com',
        petName: 'Uno',
      );

      final json = authResponse.toJson();

      expect(json['token'], 'token-teste');
      expect(json['animalId'], '68194120636f719fcd5ee5fd');
      expect(json['userId'], '68f01b12a7cdce64abaf3c17');
      expect(json['nome'], 'Gabriel');
      expect(json['email'], 'grspirlandelli@gmail.com');
      expect(json['petName'], 'Uno');
    });

    test('Deve fazer round-trip JSON corretamente', () {
      final original = AuthResponse(
        token: 'token-teste',
        animalId: '68194120636f719fcd5ee5fd',
        userId: '68f01b12a7cdce64abaf3c17',
        nome: 'Gabriel',
        email: 'grspirlandelli@gmail.com',
        petName: 'Uno',
      );

      final json = original.toJson();
      final restored = AuthResponse.fromJson(json);

      expect(restored.token, original.token);
      expect(restored.animalId, original.animalId);
      expect(restored.userId, original.userId);
      expect(restored.nome, original.nome);
      expect(restored.email, original.email);
      expect(restored.petName, original.petName);
    });
  });
}

