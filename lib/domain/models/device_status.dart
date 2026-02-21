class DeviceStatus {
  final String deviceId;
  final bool isOnline;
  final int batteryLevel;
  final DateTime lastSync;
  final bool isSafe;

  DeviceStatus({
    required this.deviceId,
    required this.isOnline,
    required this.batteryLevel,
    required this.lastSync,
    required this.isSafe,
  });

  factory DeviceStatus.fromMap(Map<String, dynamic> data, String id) {
    bool parseBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return defaultValue;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DeviceStatus(
      deviceId: id,
      isOnline: parseBool(data['is_online'], false),
      batteryLevel: parseInt(data['battery_level']),
      lastSync: data['last_sync'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(data['last_sync'].toString()) ?? DateTime.now().millisecondsSinceEpoch) 
        : DateTime.now(),
      isSafe: parseBool(data['is_safe'], true),
    );
  }
}
