import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/models/location_model.dart';

void main() {
  group('LocationData', () {
    test('Deve criar LocationData com campos de área segura', () {
      final locationData = LocationData(
        id: '68f1998abe85fc53e673e2f1',
        data: '2025-10-16T22:19:37.000-03:00',
        latitude: -20.505868,
        longitude: -47.406911,
        animal: '68194120636f719fcd5ee5fd',
        coleira: '6819475baa479949daccea94',
        isOutsideSafeZone: true,
        distanciaDoPerimetro: 126.5215767165183,
      );

      expect(locationData.id, '68f1998abe85fc53e673e2f1');
      expect(locationData.latitude, -20.505868);
      expect(locationData.longitude, -47.406911);
      expect(locationData.isOutsideSafeZone, true);
      expect(locationData.distanciaDoPerimetro, 126.5215767165183);
    });

    test('Deve fazer parse de JSON com campos de área segura', () {
      final json = {
        'id': '68f1998abe85fc53e673e2f1',
        'data': '2025-10-16T22:19:37.000-03:00',
        'latitude': -20.505868,
        'longitude': -47.406911,
        'animal': '68194120636f719fcd5ee5fd',
        'coleira': '6819475baa479949daccea94',
        'isOutsideSafeZone': true,
        'distanciaDoPerimetro': 126.5215767165183,
      };

      final locationData = LocationData.fromJson(json);

      expect(locationData.id, '68f1998abe85fc53e673e2f1');
      expect(locationData.isOutsideSafeZone, true);
      expect(locationData.distanciaDoPerimetro, 126.5215767165183);
    });

    test('Deve fazer parse de JSON sem campos de área segura', () {
      final json = {
        'id': '68f1998abe85fc53e673e2f1',
        'data': '2025-10-16T22:19:37.000-03:00',
        'latitude': -20.505868,
        'longitude': -47.406911,
        'animal': '68194120636f719fcd5ee5fd',
        'coleira': '6819475baa479949daccea94',
      };

      final locationData = LocationData.fromJson(json);

      expect(locationData.id, '68f1998abe85fc53e673e2f1');
      expect(locationData.isOutsideSafeZone, null);
      expect(locationData.distanciaDoPerimetro, null);
    });

    test('Deve criar LocationData com animal dentro da área segura', () {
      final locationData = LocationData(
        id: 'test-id',
        data: '2025-10-16T22:19:37.000-03:00',
        latitude: -20.505868,
        longitude: -47.406911,
        animal: 'animal-id',
        coleira: 'coleira-id',
        isOutsideSafeZone: false,
        distanciaDoPerimetro: 45.5,
      );

      expect(locationData.isOutsideSafeZone, false);
      expect(locationData.distanciaDoPerimetro, 45.5);
    });
  });

  group('LocationResponse', () {
    test('Deve fazer parse de LocationResponse com múltiplas localizações', () {
      final json = {
        'content': [
          {
            'id': '68f1998abe85fc53e673e2f1',
            'data': '2025-10-16T22:19:37.000-03:00',
            'latitude': -20.505868,
            'longitude': -47.406911,
            'animal': '68194120636f719fcd5ee5fd',
            'coleira': '6819475baa479949daccea94',
            'isOutsideSafeZone': true,
            'distanciaDoPerimetro': 126.5215767165183,
          },
          {
            'id': 'another-id',
            'data': '2025-10-16T22:20:00.000-03:00',
            'latitude': -20.506,
            'longitude': -47.407,
            'animal': '68194120636f719fcd5ee5fd',
            'coleira': '6819475baa479949daccea94',
            'isOutsideSafeZone': false,
            'distanciaDoPerimetro': 30.0,
          },
        ]
      };

      final response = LocationResponse.fromJson(json);

      expect(response.content.length, 2);
      expect(response.content[0].isOutsideSafeZone, true);
      expect(response.content[1].isOutsideSafeZone, false);
      expect(response.firstItem?.id, '68f1998abe85fc53e673e2f1');
    });
  });
}

