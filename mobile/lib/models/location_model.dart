class LocationResponse {
  final List<LocationData> content;

  LocationResponse({required this.content});

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>;
    return LocationResponse(
      content: contentList.map((item) => LocationData.fromJson(item)).toList(),
    );
  }

  LocationData? get firstItem => content.isNotEmpty ? content.first : null;
}

class LocationData {
  final String id;
  final String data;
  final double latitude;
  final double longitude;
  final String animal;
  final String coleira;
  // Novos campos para área segura
  final bool? isOutsideSafeZone;
  final double? distanciaDoPerimetro;

  LocationData({
    required this.id,
    required this.data,
    required this.latitude,
    required this.longitude,
    required this.animal,
    required this.coleira,
    this.isOutsideSafeZone,
    this.distanciaDoPerimetro,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'],
      data: json['data'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      animal: json['animal'],
      coleira: json['coleira'],
      // Novos campos da API
      isOutsideSafeZone: json['isOutsideSafeZone'] as bool?,
      distanciaDoPerimetro: json['distanciaDoPerimetro'] != null
          ? (json['distanciaDoPerimetro'] as num).toDouble()
          : null,
    );
  }
}
