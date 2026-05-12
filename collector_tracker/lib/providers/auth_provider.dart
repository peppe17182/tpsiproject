import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token != null) {
      _isAuthenticated = true;
      try {
        await fetchMe();
      } catch (e) {
        _isAuthenticated = false;
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> fetchMe() async {
    final response = await _apiService.get('/auth/me');
    _currentUser = User.fromJson(response['user']);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final token = response['api_token'] ?? response['token']; // Adjust based on actual API
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', token);
        _isAuthenticated = true;
        await fetchMe();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      await _apiService.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
