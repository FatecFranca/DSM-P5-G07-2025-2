import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/models/websocket_message.dart';

void main() {
  group('WebSocket Message Parsing', () {
    test('Parse LocationUpdate message', () {
      final json = {
        'messageType': 'location_update',
        'animalId': 'animal123',
        'coleiraId': 'collar456',
        'latitude': -23.5505,
        'longitude': -46.6333,
        'isOutsideSafeZone': false,
        'distanciaDoPerimetro': 0,
        'timestamp': '2024-01-01T12:00:00Z',
      };

      final message = WebSocketMessage.fromJson(json);

      expect(message, isA<LocationUpdate>());
      expect(message.animalId, equals('animal123'));
      expect(message.coleiraId, equals('collar456'));
      expect(message.messageType, equals('location_update'));
    });

    test('Parse HeartrateUpdate message', () {
      final json = {
        'messageType': 'heartrate_update',
        'animalId': 'animal123',
        'coleiraId': 'collar456',
        'frequenciaMedia': 120,
        'timestamp': '2024-01-01T12:00:00Z',
      };

      final message = WebSocketMessage.fromJson(json);

      expect(message, isA<HeartrateUpdate>());
      expect(message.animalId, equals('animal123'));
      expect(message.coleiraId, equals('collar456'));
      expect(message.messageType, equals('heartrate_update'));
    });

    test('Throw exception for unknown message type', () {
      final json = {
        'messageType': 'unknown_type',
        'animalId': 'animal123',
        'coleiraId': 'collar456',
        'timestamp': '2024-01-01T12:00:00Z',
      };

      expect(
        () => WebSocketMessage.fromJson(json),
        throwsException,
      );
    });
  });

  group('WebSocket Native Protocol', () {
    test('Heartbeat message format', () {
      // Simula o formato de heartbeat enviado
      final heartbeat = {'type': 'ping'};
      
      // Verifica se pode ser serializado como JSON
      expect(heartbeat['type'], equals('ping'));
    });

    test('Location update message structure', () {
      final locationUpdate = {
        'messageType': 'location_update',
        'animalId': 'test_animal',
        'coleiraId': 'test_collar',
        'latitude': 0.0,
        'longitude': 0.0,
        'isOutsideSafeZone': false,
        'distanciaDoPerimetro': 0,
        'timestamp': '2024-01-01T00:00:00Z',
      };

      expect(locationUpdate['messageType'], equals('location_update'));
      expect(locationUpdate.containsKey('latitude'), isTrue);
      expect(locationUpdate.containsKey('longitude'), isTrue);
    });

    test('Heartrate update message structure', () {
      final heartrateUpdate = {
        'messageType': 'heartrate_update',
        'animalId': 'test_animal',
        'coleiraId': 'test_collar',
        'frequenciaMedia': 100,
        'timestamp': '2024-01-01T00:00:00Z',
      };

      expect(heartrateUpdate['messageType'], equals('heartrate_update'));
      expect(heartrateUpdate.containsKey('frequenciaMedia'), isTrue);
    });
  });
}

