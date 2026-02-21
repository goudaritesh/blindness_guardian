class LocationLog {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationLog({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationLog.fromMap(Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return LocationLog(
      latitude: parseDouble(data['lat']),
      longitude: parseDouble(data['lng']),
      timestamp: data['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(data['timestamp'].toString()) ?? DateTime.now().millisecondsSinceEpoch) 
        : DateTime.now(),
    );
  }
}
