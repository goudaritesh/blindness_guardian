import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/api_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/global_keys.dart';
import '../../domain/models/alert.dart';
import '../widgets/active_alert_dialog.dart' show ActiveAlertDialog;

class AlertProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socketService = SocketService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Alert> _alerts = [];
  List<Alert> get alerts => _alerts;
  
  Alert? _activeAlert;
  Alert? get activeAlert => _activeAlert;

  String? _showingDialogId;

  void listenToAlerts(String deviceId) {
    _socketService.connect(deviceId);

    // Initial fetch of unresolved alerts
    fetchHistory(deviceId);

    _socketService.on('emergency_alert', (data) {
      try {
        final alert = Alert.fromMap(data, data['id'].toString());
        _activeAlert = alert;
        _alerts.insert(0, alert);
        _triggerEmergencyResponse(alert);
        notifyListeners();
      } catch (e) {
        debugPrint("Alert signal error: $e");
      }
    });
  }

  Future<List<Alert>> fetchHistory(String deviceId) async {
    try {
      final response = await _api.get('${ApiConstants.alerts}/$deviceId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _alerts = data.map((json) => Alert.fromMap(json, json['id'].toString())).toList();
        
        // If there's a fresh unresolved SOS, activate it
        final unresolved = _alerts.where((a) => !a.resolved).toList();
        if (unresolved.isNotEmpty) {
           final latest = unresolved.first;
           final int ageMins = DateTime.now().difference(latest.timestamp).inMinutes.abs();
           if (ageMins < 5) {
             _activeAlert = latest;
             _triggerEmergencyResponse(latest);
           }
        }
        notifyListeners();
        return _alerts;
      }
    } catch (e) {
      debugPrint("Fetch alerts error: $e");
    }
    return _alerts;
  }

  void _triggerEmergencyResponse(Alert alert) {
    _triggerLoudAlarm();
    _showEmergencyDialog(alert);
  }

  void _showEmergencyDialog(Alert alert) {
    if (_showingDialogId != alert.id) {
       _showingDialogId = alert.id;
       WidgetsBinding.instance.addPostFrameCallback((_) {
         final context = navigatorKey.currentContext;
         if (context != null) {
           showDialog(
             context: context,
             barrierDismissible: false,
             builder: (_) => const ActiveAlertDialog(),
           );
         }
       });
    }
  }

  Future<void> _triggerLoudAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/loud_alarm.mp3'));
    } catch(e) { /* ignore */ }
  }

  Future<void> markAsSafe(String alertId) async {
    try {
      final response = await _api.put('${ApiConstants.alerts}/$alertId/resolve', {});
      if (response.statusCode == 200) {
        _activeAlert = null;
        _showingDialogId = null;
        _audioPlayer.stop();
        // Update local list
        final index = _alerts.indexWhere((a) => a.id == alertId);
        if (index != -1) {
           _alerts[index] = Alert(
             id: _alerts[index].id,
             type: _alerts[index].type,
             timestamp: _alerts[index].timestamp,
             latitude: _alerts[index].latitude,
             longitude: _alerts[index].longitude,
             resolved: true,
             imageUrl: _alerts[index].imageUrl,
           );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Resolve error: $e");
    }
  }
}
