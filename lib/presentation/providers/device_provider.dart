import 'package:flutter/material.dart';
import '../../core/services/socket_service.dart';
import '../../domain/models/device_status.dart';

class DeviceProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  DeviceStatus? _status;
  DeviceStatus? get status => _status;

  String? _currentDeviceId;

  void listenToDevice(String deviceId) {
    if (_currentDeviceId == deviceId) return;
    _currentDeviceId = deviceId;
    
    _socketService.connect(deviceId);

    _socketService.on('status_update', (data) {
      try {
        _status = DeviceStatus.fromMap(data, deviceId);
        notifyListeners();
      } catch (e) {
        debugPrint("Status update error: $e");
      }
    });
  }

  void stopListening() {
    _socketService.off('status_update');
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
