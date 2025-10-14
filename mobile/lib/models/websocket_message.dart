abstract class WebSocketMessage {
  final String messageType;
  final String animalId;
  final String coleiraId;
  final String timestamp;

  WebSocketMessage({
    required this.messageType,
    required this.animalId,
    required this.coleiraId,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    switch (json['messageType']) {
      case 'location_update':
        return LocationUpdate.fromJson(json);
      case 'heartrate_update':
        return HeartrateUpdate.fromJson(json);
      default:
        throw Exception('Unknown message type: ${json['messageType']}');
    }
  }
}

class LocationUpdate extends WebSocketMessage {
  final double latitude;
  final double longitude;
  final bool isOutsideSafeZone;
  final double distanciaDoPerimetro;

  LocationUpdate({
    required super.messageType,
    required super.animalId,
    required super.coleiraId,
    required super.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isOutsideSafeZone,
    required this.distanciaDoPerimetro,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      messageType: json['messageType'],
      animalId: json['animalId'],
      coleiraId: json['coleiraId'],
      timestamp: json['timestamp'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isOutsideSafeZone: json['isOutsideSafeZone'],
      distanciaDoPerimetro: (json['distanciaDoPerimetro'] as num).toDouble(),
    );
  }
}

class HeartrateUpdate extends WebSocketMessage {
  final int frequenciaMedia;

  HeartrateUpdate({
    required super.messageType,
    required super.animalId,
    required super.coleiraId,
    required super.timestamp,
    required this.frequenciaMedia,
  });

  factory HeartrateUpdate.fromJson(Map<String, dynamic> json) {
    return HeartrateUpdate(
      messageType: json['messageType'],
      animalId: json['animalId'],
      coleiraId: json['coleiraId'],
      timestamp: json['timestamp'],
      frequenciaMedia: json['frequenciaMedia'],
    );
  }
}
