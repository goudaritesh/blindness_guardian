import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/daily_stats.dart';

class StatsProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  DailyStats? _todayStats;
  DailyStats? get todayStats => _todayStats;

  Future<void> fetchTodayStats(String deviceId) async {
    try {
      // For now using placeholder, as stats logic needs a proper endpoint in index.js
      // But we can implement a GET /api/stats/:deviceId
      final response = await _api.get('${ApiConstants.baseUrl}/api/stats/$deviceId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _todayStats = DailyStats.fromMap(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Fetch stats error: $e");
    }
  }
}
