class DailyStats {
  final double distanceKm;
  final int obstaclesAvoided;
  final double safeHours;
  final DateTime lastUpdated;

  DailyStats({
    required this.distanceKm,
    required this.obstaclesAvoided,
    required this.safeHours,
    required this.lastUpdated,
  });

  factory DailyStats.fromMap(Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DailyStats(
      distanceKm: parseDouble(data['distance']),
      obstaclesAvoided: parseInt(data['obstacles']),
      safeHours: parseDouble(data['safe_hours']),
      lastUpdated: data['last_updated'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(data['last_updated'].toString()) ?? DateTime.now().millisecondsSinceEpoch) 
        : DateTime.now(),
    );
  }
}
