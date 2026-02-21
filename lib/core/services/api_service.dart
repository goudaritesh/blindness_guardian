import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  bool get isAuthenticated => _token != null;
  String? get token => _token;

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> get(String url) async {
    return await http.get(
      Uri.parse(url),
      headers: _headers,
    );
  }

  Future<http.Response> put(String url, Map<String, dynamic> data) async {
    return await http.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );
  }
}
