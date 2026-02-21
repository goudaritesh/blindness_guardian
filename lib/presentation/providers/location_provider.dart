import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/location_log.dart';

class LocationProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  final ApiService _api = ApiService();
  
  LocationLog? _currentLocation;
  List<LocationLog> _history = [];
  
  LocationLog? get currentLocation => _currentLocation;
  List<LocationLog> get history => _history;

  double _geoFenceRadius = 500;
  double get geoFenceRadius => _geoFenceRadius;
  
  void listenToLocation(String deviceId) {
    _socketService.connect(deviceId);

    _socketService.on('location_update', (data) {
      try {
        final log = LocationLog.fromMap(data);
        _currentLocation = log;
        _history.add(log);
        if (_history.length > 100) _history.removeAt(0); // Keep memory clean
        notifyListeners();
      } catch (e) {
        debugPrint("Location update error: $e");
      }
    });
  }

  Future<void> loadSettings(String userId) async {
    try {
      final response = await _api.get('${ApiConstants.baseUrl}/api/users/$userId/settings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _geoFenceRadius = (data['geo_fence_radius'] ?? 500).toDouble();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Load settings error: $e");
    }
  }

  Future<void> setGeoFenceRadius(String userId, double radius) async {
    _geoFenceRadius = radius;
    notifyListeners();
    try {
      await _api.put('${ApiConstants.baseUrl}/api/users/$userId/settings', {
        'geo_fence_radius': radius
      });
    } catch (e) {
       debugPrint("Save setting error: $e");
    }
  }

  void stopListening() {
    _socketService.off('location_update');
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
