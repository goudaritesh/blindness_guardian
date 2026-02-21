import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/guardian_user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  GuardianUser? _guardianUser;
  bool _isLoading = true;

  GuardianUser? get user => _guardianUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _api.isAuthenticated;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _api.init();
    // In a real app, you might want a /api/auth/me to verify token and fetch user
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _api.saveToken(data['token']);
        
        final userData = data['user'];
        _guardianUser = GuardianUser(
          uid: userData['id'],
          email: userData['email'],
          name: userData['name'],
          phone: '', // Can be added to DB later
          deviceId: userData['devices']?.isNotEmpty == true ? userData['devices'][0]['id'] : '',
        );
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String email, String password, String name, String phone, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(ApiConstants.signup, {
        'email': email,
        'password': password,
        'name': name,
        'deviceId': deviceId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _api.saveToken(data['token']);
        
        final userData = data['user'];
        _guardianUser = GuardianUser(
          uid: userData['id'],
          email: userData['email'],
          name: userData['name'],
          phone: phone,
          deviceId: deviceId,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Signup error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _guardianUser = null;
    notifyListeners();
  }
}
