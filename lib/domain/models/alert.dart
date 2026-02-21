class Alert {
  final String id;
  final String type; // 'SOS', 'FALL', 'GEO_FENCE_BREACH'
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final bool resolved;

  Alert({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.resolved,
  });

  factory Alert.fromMap(Map<String, dynamic> data, String id) {
    // Helper to safely parse numbers from strings or numbers
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper to safely parse boolean
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      return false;
    }

    // Parse timestamp - handle seconds, milliseconds, and strings
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime(2000); 
      int? ms = int.tryParse(value.toString());
      if (ms == null) return DateTime(2000);
      
      // If it's 10 digits, it's seconds (Unix timestamp common from ESP32)
      if (ms < 10000000000) {
        ms *= 1000;
      }
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    return Alert(
      id: id,
      type: data['type']?.toString() ?? 'UNKNOWN',
      timestamp: parseTimestamp(data['timestamp']),
      latitude: parseDouble(data['lat']),
      longitude: parseDouble(data['lng']),
      imageUrl: data['image_url']?.toString(),
      resolved: parseBool(data['resolved']),
    );
  }
}
