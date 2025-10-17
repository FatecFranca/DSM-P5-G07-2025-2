class LatestHeartbeat {
  final int frequenciaMedia;

  LatestHeartbeat({required this.frequenciaMedia});

  factory LatestHeartbeat.fromJson(Map<String, dynamic> json) {
    return LatestHeartbeat(
      frequenciaMedia: json['frequenciaMedia'],
    );
  }
}